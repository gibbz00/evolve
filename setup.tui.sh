#!/bin/sh

# Following recommendations from: 
    # https://hub.docker.com/_/archlinux/
    # https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
    # https://wiki.archlinux.org/title/installation_guide
    # https://wiki.archlinux.org/title/General_recommendations

COUNTRY='SE'

## PREPARATIONS 
set -e

pacman_setup() {
    pacman-key --init

    # Select mirror servers by download rate
    # (pacman-contrib includes rankmirrors script)
    pacman -S pacman-contrib --noconfirm --needed
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    curl -s "https://archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=https&use_mirror_status=on" \
    | sed -e 's/^#Server/Server/' -e '/^#/d' \
    | rankmirrors -v -n 5 - \
    > /etc/pacman.d/mirrorlist
}

install_packages() {
    # Bring existing packages up to date
    pacman -Syyu --noconfirm

    # IMPROVEMENT: just do this with grep
    # TODO: make sure that tabs are trimmed away
    PACKAGES=$(sed -e '/^#/d' "./packages.tui" | tr '\n' ' ')
    pacman -S "$PACKAGES" --noconfirm --needed
}

user_setup() {
    # TODO: check that promts are understandable
    passwd
    # TODO: test that skel flag works
    useradd --skel /dev/null --create-home --shell /bin/bash --groups users,wheel gibbz
    passwd gibbz
}

# networkmanager service setup
# TODO: how is network setup on fresh machines?
#   following is a requirement for networkmanager-dmenu-git
#systemctl start NetworkManager.service
#systemctl enable NetworkManager.service
# TODO: make sure that dhcpcd and systemd-networkd are not enabled or started

# File part of the Evolve project. 
# Force bash to follow xdg-base spec
# TODO: 
    # check that profile.d directory exists and that they are sourced in /etc/profile
    # check that symbolic link does not aleady exist by another user
    # check that files to be linked actually exist
    # xdg config home should be used
ln /home/whiz/.config/bash/bash_login_xdg.sh /etc/profile.d/
ln /home/whiz/.config/bash/bash_interactive_xdg.sh /etc/bashrc.d/

# Swaps escape with caps and lctrl with lalt  
# TODO: change to using the showkey(1) setkeycodes(8) API instead of this evtest, evdev-descrribe, udevrules, systemd-hwdb fuckfest
sudo ln /home/whiz/.config/udev/hwdb.d/90-custom-keyboard-bindings.hwdb /etc/udev/hwdb.d/
# Update Hardware Dababase Index (hwdb.bin)
sudo systemd-hwdb update
# Trigger reload of hwdb.bin that is normally only as part of the boot process. 
sudo udevadm trigger

# Sway privilege escalation and session activation setup
# Read more at: https://wiki.archlinux.org/title/sway#Starting
# Using seatd to avoid logind and Polkit dependencies
sudo systemctl enable seatd
sudo systemctl start seatd
upsermod gibbz --append seat

## Git setup
git config --global user.name 'gibbz00'
git config --global user.email 'gabrielhansson00@gmail.com'
# TODO: gh Authentication, see workflowy

# TODO: make sure that files in $HOME are owned by user
# sudo chown -R $USER:$USER /home/$USER
