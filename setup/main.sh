#!/bin/sh
. "./evolve.env"

. ./setup/tui.sh

if "$GUI"
then 
    . ./setup/gui.sh
fi

rm --recursive --force /root/evolve
echo "Rebooting..."
$REBOOT_REQUIRED && reboot 
