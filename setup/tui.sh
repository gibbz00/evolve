#!/bin/sh

. ./utils.sh

clock_setup() {
    # Network time syncronization
    timedatectl set-ntp true
    ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    # Raspberry Pi 4 does not include an on-board hardware clock
    if test "$HARDWARE" != 'rpi4'
    then
        hwclock --systohc
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
    # Changes to take immediate effect
    . skel/tui/.config/locale.conf
)}

pacman_setup() {
    uncomment_util "ParallelDownloads" /etc/pacman.conf
    uncomment_util "Color" /etc/pacman.conf

    pacman-key --init
    test "$HARDWARE" = "rpi4" && pacman-key --populate archlinuxarm
    # Must be run before installing any packages
    pacman -Syyu --noconfirm

    # Arch Arm treats mirrors a bit differently: https://archlinuxarm.org/about/mirrors
    if test "$HARDWARE" != "rpi4"
    then
        # Select mirror servers by download rate
        # (pacman-contrib includes rankmirrors script)
        pacman -S pacman-contrib --noconfirm --needed
        cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
        curl -s "https://archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=https&use_mirror_status=on" \
        | sed -e 's/^#Server/Server/' -e '/^#/d' \
        | rankmirrors -v -n 5 - \
        > /etc/pacman.d/mirrorlist
    fi
}

# Setup before yay since makepkg can't be run as root
user_setup() {(
    printf "%s\n%s" "$ROOT_PASSWORD" "$ROOT_PASSWORD" | passwd

    mkdir merged-skel
    # wilcard (*) doesn't match hidden files by default
    cp -r skel/tui/{*,.[!.]*} merged-skel 2>/dev/null || true 
    $GUI && cp -r skel/gui/{*,.[!.]*} merged-skel 2>/dev/null || true 

    useradd --skel merged-skel --create-home --shell /bin/bash --groups users,wheel "$USERNAME"
    printf "%s\n%s" "$USER_PASSWORD" "$USER_PASSWORD" | passwd "$USERNAME"

    case $HARDWARE in
        'rpi4')
            # remove default alarm user
            userdel --remove alarm
        ;;
    esac
)}

yay_setup() {
    pacman -S git base-devel sudo --needed --noconfirm 
    uncomment_util ' %wheel ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers
    sudo -u "$USERNAME" sh -c "
        cd /home/$USERNAME 
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg --syncdeps --install --noconfirm --needed
        cd .. && rm --recursive --force yay-bin
    "
}

bash_force_xdg_base_spec() {
    cp sys/bash_login_xdg.sh /etc/profile.d/
    # bashrc.d not included by default in Arch Linux Arm
    mkdir --parent /etc/bashrc.d
    cp sys/bash_interactive_xdg.sh /etc/bashrc.d/
    case $HARDWARE in
        'rpi4')
# To avoid indendation in /etc/bash.bashrc
code="
# Load run commmands from /etc/bashrc.d
if [ -d /etc/bashrc.d/ ]; then
    for file in /etc/bashrc.d/*.sh; do
        [ -r \"\$file\" ] && . \"\$file\" 
    done
    unset file
fi"
            echo "$code" >> '/etc/bash.bashrc'
        ;;
    esac
}

swap_keys_option() {
    ($SWAP_CAPS_ESCAPE || $SWAP_LCTRL_LALT) || return 0
    
    $SWAP_CAPS_ESCAPE && cp sys/90-swap-caps-escape.hwdb /etc/udev/hwdb.d/
    $SWAP_LCTRL_LALT && cp sys/90-swap-lctrl-lalt.hwdb /etc/udev/hwdb.d/

    systemd-hwdb update
    udevadm trigger
}

package_setups() {(
    # Git
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL_ADRESSS"
    git config --global advice.addIgnoredFile false

    # Github
    if test -n "$GITHUB_TOKEN"
    then
        # HACK: creation of gitconfig doesn't respect .config of XDG_CONFIG_HOME as of 2022-09-28
        #   better to solve issue upstream rather removing .config hardcode
        sudo -u "$USERNAME" sh -c "
	    yay -S --noconfirm --needed github-cli
            echo $GITHUB_TOKEN | gh auth login --with-token 
	    cd /home/$USERNAME
            gh auth setup-git
            mkdir --parent ~/.config/git
            mv .gitconfig ~/.config/git/config
        "
    fi
)}

clock_setup
localization_setup
pacman_setup
user_setup
yay_setup
install_packages_util "packages/tui"
bash_force_xdg_base_spec
swap_keys_option
package_setups
