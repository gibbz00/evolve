#!/bin/bash
. ./context.sh

# helper funlction to make sure xdg base exports are used when using sh with user
suserdo() {
    sudo -u "$USERNAME" sh -c "
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

    if test "$HARDWARE" = 'rpi4'
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
    pacman -S rustup --needed --noconfirm
    suserdo "
        rustup default $RUST_TOOLCHAIN
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

misc_setup() {(
    # Supress some error messages in console
    cp sys/20-quiet-printk.conf /etc/sysctl.d/

    # Consolefont setting
    cp sys/vconsole.conf /etc/
    # Make changes immediate
    test "$HARDWARE" = "rpi4" && systemctl restart systemd-vconsole-setup

    suserdo "
        git config --global user.name $GIT_USERNAME
        git config --global user.email $GIT_EMAIL_ADRESSS
        git config --global advice.addIgnoredFile false
    "

    # Github
    if test -n "$GITHUB_TOKEN"
    then
        suserdo "
            paru -S --noconfirm --needed github-cli
            echo $GITHUB_TOKEN | gh auth login --with-token 
            gh auth setup-git
        "
    fi

    if test "$SSH_SERVER" = "true"
    then
        pacman -S openssh --needed --noconfirm
        systemctl enable sshd
    fi
)}
  
clock_setup
localization_setup
user_setup
paru_setup
# Done before package installation in order to aviod package conflicts with rust-analyzer
test "$RUST_TOOLCHAIN" && setup_rust
install_packages_util "packages/tui"
bash_force_xdg_base_spec
swap_keys_option
test "$HARDWARE" = "uefi" && install_bootloader
misc_setup

if "$GUI"
then 
    . ./setup/gui.sh
fi

rm -rf /root/evolve
