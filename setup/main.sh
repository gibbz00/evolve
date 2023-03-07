#!/bin/sh
set -e

. "./evolve.env"

if test "$HARDWARE" = "wrk" && ! test -d /sys/firmware/efi/efivars
then
    echo "System not booted in UEFI mode, aborting..."
    exit 1
fi

. ./setup/tui.sh

if "$GUI"
then 
    . ./setup/gui.sh
fi

rm --recursive --force /root/evolve

# Setup depends on some systemd services that can't be started in chroot.
echo "Rebooting..."
reboot 
