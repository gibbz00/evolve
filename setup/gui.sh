#!/bin/sh
. ./utils.sh

sway_setup() {
    # Sway privilege escalation and session activation setup
    # Using seatd to avoid logind and Polkit dependencies
    # Read more at: https://wiki.archlinux.org/title/sway#Starting
    systemctl enable seatd
    systemctl start seatd
    gpasswd --add $USERNAME seat
    
    echo \
"$(test $HARDWARE = 'rpi4' && echo 'export WLR_NO_HARDWARE_CURSORS=1')
[[ ! \$DISPLAY && XDG_VTNR -eq 1 ]] && exec sway $($NVIDIA_GPU && echo "--unsupported-gpu")" \
	>> /home/"$USERNAME"/.config/bash/profile.d/sway.bash

    # Using personal version until https://github.com/swaywm/sway/pull/7197 gets merged.
    cp sys/inactive-windows-transparency.py /usr/share/sway/scripts/
}

misc_packages_setup() {
    # networkmanager-dmenu-git uses networkmanager
    # whilst arch linux uses systemd-networkd out of the box
    systemctl stop systemd-networkd
    systemctl disable systemd-networkd
    systemctl start NetworkManager.service
    systemctl enable NetworkManager.service
}

install_packages_util "packages/gui"
sway_setup
misc_packages_setup
