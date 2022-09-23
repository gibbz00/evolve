#!/bin/sh
set -e 

select_hardware() {
    supported_hardware="
        raspberry_pi_4
    "

    while getopts "h:" flag
    do
        case "$flag" in
            h)
                echo "$flag $OPTARG"
                if (echo "$supported_hardware" | grep --quiet --fixed-string --word-regexp "$OPTARG")
                then
                    HARDWARE="$OPTARG"
                else 
                    printf "Invalid hardware option. Choose on of: %s" "$supported_hardware"
                fi
            ;;
            *)
                printf "Specify hardware with the -h <hardware_option> flag. Possible hardware options: %s" "$supported_hardware"
            ;;
        esac
    done 
}

select_device() {
    echo "Make sure that the boot medium is NOT plugged in. Press enter once that is the case."
    read -r
    # Finding device name
    lsblk > state1.log
    echo "Insert boot medium, press enter when done."
    read -r
    lsblk > state2.log
    # get device name
    device=$(
        grep --invert-match --line-regexp --fixed-strings --file /tmp/state1.log /tmp/state2.log \
        | head --lines 1 \
        | grep --only-matching --regexp "^\w*"
    )
    rm state1.log state2.log
    echo "Found boot device $device."
}

partition_device() {
    # Wipe partition-table signatures
    wipefs --all /dev/"$device"

    case $HARDWARE in
        'raspberry_pi_4')
            # Table type
            parted --script --align optimal "$device" mklabel "msdos"
            # Boot Partition
            parted --script --align optimal "$device" mkpart primary fat32 "1MiB" "1024MiB"
            parted --script --align optimal "$device" set 1 boot on
            # Root Partition
            parted --script --align optimal "$device" mkpart primary "1024MiB" "100%"
        ;;
    esac

    # Inform kernel about new partition table changes
    partprobe "$device"
}

## Main ##
select_hardware
select_device
partition_device
