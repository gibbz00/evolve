#!/bin/sh
set -e

# networkmanager-dmenu-git uses networkmanager
# arch linux uses systemd-networkd out of the box, must be disabled for gui version
# systemctl stop systemd-networkd
# systemctl disable systemd-networkd
# systemctl start NetworkManager.service
# systemctl enable NetworkManager.service

# Sway privilege escalation and session activation setup
# Read more at: https://wiki.archlinux.org/title/sway#Starting
# Using seatd to avoid logind and Polkit dependencies
systemctl enable seatd
systemctl start seatd
usermod "$USERNAME" --append seat

