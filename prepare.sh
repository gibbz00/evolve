#!/bin/sh
# Preparing the boot medium for https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
set -e 

echo "Make sure that the boot medium is NOT plugged in. Press enter once that is the case."
read -r
# Finding device name
lsblk > /tmp/state1.log
echo "Insert boot medium, press enter when done."
read -r
lsblk > /tmp/state2.log
# get device name
device=$(
    grep --invert-match --line-regexp --fixed-strings --file /tmp/state1.log /tmp/state2.log \
    | head --lines 1 \
    | grep --only-matching --regexp "^\w*"
)
rm /tmp/prepare.log
echo "Found boot device $device."
(sfdisk --dump /dev/"$device") > partitions.bak
# clear out any partitions
