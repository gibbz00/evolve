#!/bin/bash
. ./context.sh

# helper funlction to make sure xdg base exports are used when using sh with user
suserdo() {
    su "$USERNAME" --login -c "
        cd /home/$USERNAME 
        . .config/bash/xdg_base.env
        $1
    "
}

clock_setup() {
    # Network time syncronization
    ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    # Raspberry Pi 4 does not include an on-board hardware clock
    if test "$HARDWARE" != 'rpi4'
    then
        hwclock --systohc
    else 
        # But because it is not booted under chroot, it can on the other hand be configured to use the Network Time Protocol here.
        # (timedatectl requires an active D-Bus, which isn't present in chroot.)
        timedatectl set-ntp true
    fi
}

localization_setup() {(
    # Extract mentioned locales 
    locales=$(grep --only-matching --perl-regexp "(?<==)\S*" skel/tui/.config/locale.conf | uniq)
    for locale in $locales
    do
        uncomment_util "$locale UTF-8" /etc/locale.gen
    done
    # Generate locales
    locale-gen
    # For changes to take an immediate effect
    . skel/tui/.config/locale.conf
)}

# Setup before paru since makepkg can't be run as root
user_setup() {(
    printf "%s\n%s" "$ROOT_PASSWORD" "$ROOT_PASSWORD" | passwd

    mkdir merged-skel
    # || true to supress output 
    # wilcard (*) doesn't match hidden files by default
    cp -r --preserve=mode skel/tui/{*,.[!.]*} merged-skel 2>/dev/null || true 
    $GUI && cp -r --preserve=mode skel/gui/{*,.[!.]*} merged-skel 2>/dev/null || true 

    useradd --skel merged-skel --create-home --shell /bin/bash --groups users,wheel "$USERNAME"
    printf "%s\n%s" "$USER_PASSWORD" "$USER_PASSWORD" | passwd "$USERNAME"

    if test "$HARDWARE" = 'rpi4' || test "$HARDWARE" = 'm1'
    then
        # remove default alarm user
        userdel --remove alarm
    fi
)}

paru_setup() {
    pacman -S git base-devel sudo --needed --noconfirm 
    uncomment_util ' %wheel ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers
    suserdo "
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg --syncdeps --install --noconfirm --needed
        cd .. && rm --recursive --force paru
    "
}

rust_setup() {
    pacman -S rustup mold --needed --noconfirm
    suserdo "
        rustup default $RUST_TOOLCHAIN
        rustup component add rust-analyzer
    "
    # https://github.com/rust-lang/cargo/issues/1734
    suserdo "
        ln -s $XDG_CONFIG_HOME/cargo/config.toml $CARGO_HOME/cargo/
    "
}

bash_force_xdg_base_spec() {
    # Appended to /etc/profile rather then added to /etc/profile.d to ensure
    # that everything in profile.d/ (e.g locale.sh) is sourced first. 
    cat sys/bash_login_xdg.sh >> /etc/profile
    # bashrc.d not included by default in Arch Linux distro
    mkdir --parent /etc/bashrc.d
    cp sys/bash_interactive_xdg.sh /etc/bashrc.d/
    code="
# Load run commmands from /etc/bashrc.d
if [ -d /etc/bashrc.d/ ]; then
    for file in /etc/bashrc.d/*.sh; do
        [ -r \"\$file\" ] && . \"\$file\" 
    done
    unset file
fi"
    echo "$code" >> '/etc/bash.bashrc'
}

bluetooth_setup() {
    pacman -S bluez bluez-utils --needed --noconfirm
    systemctl enable bluetooth
}

swap_keys_option() {
    ($SWAP_CAPS_ESCAPE || $SWAP_LCTRL_LALT) || return 0
    
    $SWAP_CAPS_ESCAPE && cp sys/90-swap-caps-escape.hwdb /etc/udev/hwdb.d/
    $SWAP_LCTRL_LALT && cp sys/90-swap-lctrl-lalt.hwdb /etc/udev/hwdb.d/

    # TODO: works in chroot?
    systemd-hwdb update
    udevadm trigger
}

install_bootloader() {
    mkdir --parents /boot/EFI    
    pacman -S "$CPU_MANUFACTURER-ucode" --needed --noconfirm
    pacman -S refind gdisk --needed --noconfirm 
    refind-install --root /boot
    # A refind_linux.conf would normally not be neccessary the bootlaoader supports autodetection of kernel parameters, root partition and initramfs.
    # But this breaks down when an extra initrd key is used for the microcode img, hence the workarounds.
    echo "\"Boot using default options\" \"root=$ROOT_DEVICE rw initrd=$CPU_MANUFACTURER-ucode.img initrd=initramfs-linux.img\"" > /boot/refind_linux.conf
    mkdir --parents /etc/pacman.d/hooks
    cp sys/refind.hook /etc/pacman.d/hooks/
    suserdo "
        paru -S refind-theme-regular-git --needed --noconfirm
    "
    cp sys/refind-theme.conf /boot/EFI/refind/themes/refind-theme-regular/theme.conf
    echo "
include themes/refind-theme-regular/theme.conf
    " >> /boot/EFI/refind/refind.conf
}

git_setup() {
    if test "$GIT_USERNAME$GIT_EMAIL_ADRESSS$GITHUB_TOKEN"
    then
        # single quotes to avioid preemptive variable expansion
        # shellcheck disable=SC2016
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
        suserdo '
            git_config_dir=$XDG_CONFIG_HOME/git
            mkdir --parents $git_config_dir
            touch $git_config_dir/config
        '
    else
        return 0
    fi

    # No `test "$ENV_VAR" &&` statements are needed as git config
    # commands will just attempt to return current value if no value
    # is provided.
    suserdo "
        git config --global user.name $GIT_USERNAME
        git config --global user.email $GIT_EMAIL_ADRESSS
        git config --global advice.addIgnoredFile false
        git config --global init.defaultBranch $GIT_DEFAULT_BRANCH
    "

    if test -n "$GITHUB_TOKEN"
    then
        suserdo "
            paru -S --noconfirm --needed github-cli
            echo $GITHUB_TOKEN | gh auth login --with-token 
            gh auth setup-git
        "
    fi
}

misc_setup() {(
    # Supress some error messages in console
    cp sys/20-quiet-printk.conf /etc/sysctl.d/

    # Consolefont setting
    cp sys/vconsole.conf /etc/
    # Make changes immediate
    test "$HARDWARE" = "rpi4" && systemctl restart systemd-vconsole-setup

    if test "$ROOTLESS_DOCKER" = "true"
    then
        pacman -S docker --needed --noconfirm

        sudo usermod -aG docker $USERNAME
        newgrp docker

        systemctl enable --now docker
    fi

    if test "$SSH_SERVER" = "true"
    then
        pacman -S openssh --needed --noconfirm
        systemctl enable --now sshd
    fi

    # GnuPG does not seem to create it by it self:
    suserdo "
        _gnu_dir="$XDG_DATA_HOME/gnupg"
        mkdir "$_gnu_dir"
        find "$_gnu_dir" -type f -exec chmod 600 {} \;
        find "$_gnu_dir" -type d -exec chmod 700 {} \;
    "
)}
  
clock_setup
localization_setup
user_setup
# Done before package installation in order to aviod package conflicts with `rust`
test "$RUST_TOOLCHAIN" &&  rust_setup
paru_setup
install_packages_util "packages/tui"
bash_force_xdg_base_spec
test "$BLUETOOTH" && bluetooth_setup
swap_keys_option
test "$HARDWARE" = "uefi" && install_bootloader
git_setup
misc_setup

if "$GUI"
then 
    . ./setup/gui.sh
fi

# Remove orphaned packages
pacman -Qtdq | pacman --noconfirm -Rns -
# Remove from target
rm -rf /root/evolve
