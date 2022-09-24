#!/bin/sh
set -e 

. ./evolve.env

check_hardware() {
    supported_hardware="
        raspberry_pi_4
    "

    if ! (echo "$supported_hardware" | grep --quiet --fixed-string --word-regexp "$HARDWARE")
    then
        printf "Invalid hardware option. Edit HARDWARE in evolve.env by choosing one of: %s" "$supported_hardware"
    fi
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
    echo "Found device: $device."
}

partition_device() {
    # Wipe partition-table signatures
    wipefs --all /dev/"$device"

    case $HARDWARE in
        'raspberry_pi_4')
            # Table type
            parted --script --align optimal /dev/"$device" \
                mklabel "msdos" \
                mkpart primary fat32 "1MiB" "1024MiB" \
                set 1 boot on \
                mkpart primary "1024MiB" "100%" \
        ;;
    esac

    # Inform kernel about new partition table changes
    partprobe /dev/"$device"
}

format_and_mount_partitions() {
    # shellcheck disable=SC2046
        # word splitting is exactly what I want in this case
    set -- $(
        lsblk --noheadings --output NAME --sort NAME \
            | grep "^$device" \
            | grep --invert-match --fixed-string --word-regexp "$device" 
    )

    BOOT_DIRECTORY="../boot"
    ROOT_DIRECTORY="../root"
    case $HARDWARE in
        'raspberry_pi_4')
            mkdir "$BOOT_DIRECTORY"
            mkfs.vfat /dev/"$1"
            mount /dev/"$1" "$BOOT_DIRECTORY"

            mkdir "$ROOT_DIRECTORY"
            mkfs.ext4 /dev/"$2"
            mount /dev/"$2" "$ROOT_DIRECTORY"
        ;;
    esac
}

download_base() {
    case $HARDWARE in
        'raspberry_pi_4')
            curl --location http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz \
                | bsdtar --extract --preserve-permissions --file - --directory "$ROOT_DIRECTORY"
            sync
            # TODO: will this work without sync?
            mv "$ROOT_DIRECTORY"/boot/* "$BOOT_DIRECTORY"
            # https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4#aarch64installation
            sed -i 's/mmcblk0/mmcblk1/g' "$ROOT_DIRECTORY"/etc/fstab
        ;;
    esac
}

misc_preparations() {
    # copy evolve scripts to root
    cp --recursive . "$ROOT_DIRECTORY"/root/evolve

    # host name set in preparation step for headless functionality
        # (easer than using nmap and testing to ssh into a bunch random of ip adresses)
    echo "$HOST_NAME" >> root/etc/hostname
}

cleanup_mounts(){
   umount "$BOOT_DIRECTORY" "$ROOT_DIRECTORY"
   rm --recursive --force "$BOOT_DIRECTORY" "$ROOT_DIRECTORY"
}

## Main ##
check_hardware
select_device
partition_device
format_and_mount_partitions
download_base
misc_preparations
cleanup_mounts
