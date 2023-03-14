#!/bin/bash
. ./setup/tui.sh
# Remove from installation medium
rm --recursive --force /root/evolve
# Setup depends on some systemd services that can't be started in chroot.
echo "Rebooting..."
reboot 
