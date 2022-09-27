#!/bin/sh

# Utility function: $1 match $2 path
uncomment(){
    sed --expression "s/^#$1/$1/" --in-place "$2"
}

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
    locales=$(grep --only-matching --perl-regexp "(?<==)\S*" skel/.config/locale.conf | uniq)
    for locale in $locales
    do
        uncomment "$locale UTF-8" /etc/locale.gen
    done
    # Generate locales
    locale-gen
    # Changes to take immediate effect
    . skel/.config/locale.conf
)}

pacman_setup() {
    uncomment "ParallelDownloads" /etc/pacman.conf
    uncomment "Color" /etc/pacman.conf

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
    passwdpromt='Enter desired password for '
    printf "%s %s:\n" "$passwdpromt" "root"
    passwd
    useradd --skel skel/ --create-home --shell /bin/bash --groups users,wheel "$USERNAME"
    printf "%s %s:\n" "$passwdpromt" "$USERNAME"
    passwd "$USERNAME"

    case $HARDWARE in
        'rpi4')
            # remove default alarm user
            userdel --remove alarm
        ;;
    esac
)}

yay_setup() {(
    pacman -S git base-devel --needed -noconfirm 
    cd /home/"$USERNAME" 
    su "$USERNAME" -c $(
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        "$USERNAME" makepkg --syncdeps --install --noconfirm --needed
        cd .. && rm -rf yay-bin
    )
)}

install_packages() {(
    PACKAGES=$(sed -e '/#/d' "./packages.tui" | tr --squeeze-repeats '\n ' ' ')
    yay -S "$PACKAGES" --noconfirm --needed
)}


bash_force_xdg_base_spec() {(
    cp skel/.config/bash/bash_login_xdg.sh /etc/profile.d/
    # bashrc.d not included by default in Arch Linux Arm
    mkdir --parent /etc/bashrc.d
    cp skel/.config/bash/bash_interactive_xdg.sh /etc/bashrc.d/
    case $HARDWARE in
        'rpi4')
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
)}

swap_keys() {
    # Swaps escape with caps and lctrl with lalt  
    cp /home/"$USERNAME"/.config/udev/hwdb.d/90-custom-keyboard-bindings.hwdb /etc/udev/hwdb.d/
    systemd-hwdb update
    udevadm trigger
}

package_setups() {(
    # Sudo
    uncomment ' %wheel ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers

    # Git
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL_ADRESSS"

    # Github
    if test -n "$GITHUB_TOKEN"
    then
        yay -S --noconfirm --needed github-cli
        echo "$GITHUB_TOKEN" | gh auth login --with-token 
    fi
)}

clock_setup
localization_setup
pacman_setup
user_setup
yay_setup
install_packages
bash_force_xdg_base_spec
swap_keys
package_setups
