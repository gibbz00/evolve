#!/bin/sh
set -e 
. ./evolve.env

check_hardware() {
    supported_hardware="
        rpi4
    "

    if ! (echo "$supported_hardware" | grep --quiet --fixed-string --word-regexp "$HARDWARE")
    then
        printf "Invalid hardware option. Edit HARDWARE in evolve.env by choosing one of: %s" "$supported_hardware"
    fi
}

select_device() {
    printf "Take out boot USB/SD-card. When NOT be plugged in; press enter."
    read -r
    # Finding device name
    lsblk > state1.log
    printf "Now insert boot USB/SD-card. When plugged in; press enter."
    read -r
    lsblk > state2.log
    # Get device name
    device=$(
        grep --invert-match --line-regexp --fixed-strings --file /tmp/state1.log /tmp/state2.log \
            | head --lines 1 \
            | grep --only-matching --regexp "^\w*"
    )
    rm state1.log state2.log
    echo "Found device: $device."
    # HACK: takes some time for the disk to get registered.
        # wipefs won't find the device without this 1 second sleep
    sleep 1s
}

partition_device() {
    # Wipe partition-table signatures
    wipefs --all /dev/"$device"

    case $HARDWARE in
        'rpi4')
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

    BOOT_DIRECTORY="./boot"
    ROOT_DIRECTORY="./root"
    case $HARDWARE in
        'rpi4')
            mkfs.vfat -v /dev/"$1"
            mkdir "$BOOT_DIRECTORY"
            mount /dev/"$1" "$BOOT_DIRECTORY"

            yes | mkfs.ext4 -v /dev/"$2"
            mkdir "$ROOT_DIRECTORY"
            mount /dev/"$2" "$ROOT_DIRECTORY"
        ;;
    esac
}

download_base() {
    case $HARDWARE in
        'rpi4')
            (
                url='http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz'
                printf "Downloading the latest Arch Linux Arm aarch64 root filesystem from:\n%s\n" $url
                curl --location $url \
                    | bsdtar --verbose --extract --preserve-permissions --file - --directory "$ROOT_DIRECTORY"
            )
            sync
            mv "$ROOT_DIRECTORY"/boot/* "$BOOT_DIRECTORY"
            # https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4#aarch64installation
            sed --in-place 's/mmcblk0/mmcblk1/g' "$ROOT_DIRECTORY"/etc/fstab
        ;;
    esac
}

misc_preparations() {
    # copy evolve scripts to root
    rsync --recursive --perms --times --verbose --exclude=$ROOT_DIRECTORY --exclude=$BOOT_DIRECTORY . "$ROOT_DIRECTORY"/root/evolve

    # host name set in preparation step for headless functionality
        # (easer than using nmap and testing to ssh into a bunch random of ip adresses)
    echo "$HOST_NAME" > $ROOT_DIRECTORY/etc/hostname

    # Allow for ssh root login
    sed --expression 's/^#PermitRootLogin.*/PermitRootLogin yes/' --in-place $ROOT_DIRECTORY/etc/ssh/sshd_config
}

cleanup(){
   umount "$BOOT_DIRECTORY" "$ROOT_DIRECTORY"
   rm --recursive --force "$BOOT_DIRECTORY" "$ROOT_DIRECTORY"
   echo "Preparation complete, boot USB/SD-card can now safely be removed."
}

## Main ##
check_hardware
select_device
partition_device
format_and_mount_partitions
download_base
misc_preparations
cleanup
