#!/bin/sh
set -e

# networkmanager service setup
# TODO: how is network setup on fresh machines? does this need to moved to tui?
#   following is a requirement for networkmanager-dmenu-git
#systemctl start NetworkManager.service
#systemctl enable NetworkManager.service
# TODO: make sure that dhcpcd and systemd-networkd are not enabled or started

# Sway privilege escalation and session activation setup
# Read more at: https://wiki.archlinux.org/title/sway#Starting
# Using seatd to avoid logind and Polkit dependencies
sudo systemctl enable seatd
sudo systemctl start seatd
upsermod $USERNAME --append seat

