#!/bin/bash
. ./context.sh

sway_setup() {
    # Sway privilege escalation and session activation setup
    # Using seatd to avoid logind and Polkit dependencies
    # Read more at: https://wiki.archlinux.org/title/sway#Starting
    systemctl enable seatd
    gpasswd --add "$USERNAME" seat
    
    _sway_config_path="/home/$USERNAME/.config/bash/profile.d/sway.bash"
    test "$HARDWARE" = 'rpi4' && echo 'export WLR_NO_HARDWARE_CURSORS=1' >> "$_sway_config_path"
    echo "[[ ! \$DISPLAY && XDG_VTNR -eq 1 ]] && exec sway" >> "$_sway_config_path"

    # Using personal version until https://github.com/swaywm/sway/pull/7197 gets merged.
    cp --preserve=mode sys/inactive-windows-transparency.py /usr/share/sway/scripts/
}

misc_packages_setup() {
    # networkmanager-dmenu-git uses networkmanager
    # whilst arch linux uses systemd-networkd out of the box
    systemctl disable systemd-networkd
    systemctl enable NetworkManager.service
  	systemctl --user enable pipewire-pulse.service
}

install_packages_util "packages/gui"
sway_setup
misc_packages_setup
