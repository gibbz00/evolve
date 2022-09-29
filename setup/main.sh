#!/bin/sh
set -e

. "../evolve.env"

. ./tui.sh

if "$GUI"
then 
    . ./gui.sh
fi

rm --recursive --force /root/evolve
su - "$USERNAME"
