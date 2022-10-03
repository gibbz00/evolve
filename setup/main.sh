#!/bin/sh
set -e

. "./evolve.env"

. ./setup/tui.sh

if "$GUI"
then 
    . ./setup/gui.sh
fi

rm --recursive --force /root/evolve
su - "$USERNAME"
