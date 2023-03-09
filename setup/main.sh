#!/bin/sh
set -e

. "./evolve.env"

. ./setup/tui.sh

rm --recursive --force /root/evolve

# Setup depends on some systemd services that can't be started in chroot.
echo "Rebooting..."
reboot 
