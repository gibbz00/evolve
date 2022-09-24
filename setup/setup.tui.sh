#!/bin/sh

# Following recommendations from: 
    # https://hub.docker.com/_/archlinux/
    # https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
    # https://wiki.archlinux.org/title/installation_guide
    # https://wiki.archlinux.org/title/General_recommendations

locale_setup () {
    # timezone using $TIMEZONE from evolve.env
    # # ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    # # hwclock --systohc
    # https://wiki.archlinux.org/title/installation_guide#Localization
    echo "stub"
}

pacman_setup() {
    pacman-key --init

    # TODO: why?
    if test $HARDWARE = "raspberry_pi_4"
    then
        pacman-key --populate archlinuxarm
    fi

    # TODO: for Arm version as well?
    # Select mirror servers by download rate
    # (pacman-contrib includes rankmirrors script)
    pacman -S pacman-contrib --noconfirm --needed
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    curl -s "https://archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=https&use_mirror_status=on" \
    | sed -e 's/^#Server/Server/' -e '/^#/d' \
    | rankmirrors -v -n 5 - \
    > /etc/pacman.d/mirrorlist
}

yay_setup() {
    echo "stub"
}

install_packages() {
    pacman -Syyu --noconfirm

    # IMPROVEMENT: just do this with grep
    # TODO: make sure that tabs are trimmed away
    PACKAGES=$(sed -e '/^#/d' "./packages.tui" | tr '\n' ' ')
    yay -S "$PACKAGES" --noconfirm --needed
}

user_setup() {
    # TODO: check that promts are understandable
    passwd
    # TODO: test that skel flag works
    # TODO: make sure that files in $HOME are owned by user, is this a given when using the skel flag?
    #   alternatively: chown -R $USER:$USER /home/$USER
    useradd --skel skel/ --create-home --shell /bin/bash --groups users,wheel $USERNAME
    # TODO: check that promts are understandable
    passwd $USERNAME

}

bash_force_xdg_base_spec() {
    # TODO: make sure that permission are correct and that they are executable.
    cp skel/.config/bash/bash_login_xdg.sh /etc/profile.d/
    cp skel/.config/bash/bash_interactive_xdg.sh /etc/bashrc.d/
}

swap_keys() {
    # Swaps escape with caps and lctrl with lalt  
    # POTENTIAL IMPROVEMENT: change to using the showkey(1) setkeycodes(8) API instead of this evtest, evdev-descrribe, udevrules, systemd-hwdb fuckfest
    cp /home/$USERNAME/.config/udev/hwdb.d/90-custom-keyboard-bindings.hwdb /etc/udev/hwdb.d/
    # Update Hardware Dababase Index (hwdb.bin)
    systemd-hwdb update
    # Trigger reload of hwdb.bin for settings to take immediate effect.
    # Relead is normall part of bootprocess. 
    udevadm trigger
}

git_setup() {
    git config --global user.name $GIT_USERNAME
    git config --global user.email $GIT_EMAIL_ADRESSS
}

github_setup() {
    echo "stub"
    # TODO: gh Authentication, see workflowy
}

