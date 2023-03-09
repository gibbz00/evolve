#!/bin/bash
. ./utils.sh
 
prepare_and_mount_partitions() {
    . ./setup/partition_algos.sh
    case "$PARTITION_ALGO" in
        'linux-only') linux-only ;;
        'windows-preinstalled') windows-preinstalled ;;
        '') ;;
    esac

    mkdir /mnt/etc 
    genfstab -U /mnt >> /mnt/etc/fstab
}

setup_mirrors() {
    # Arch Arm treats mirrors a bit differently: https://archlinuxarm.org/about/mirrors
    if test "$HARDWARE" != "rpi4"
    then
        reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
    fi
}

pacman_setup() {
    uncomment_util "ParallelDownloads" /etc/pacman.conf
    uncomment_util "Color" /etc/pacman.conf
    case $HARDWARE in 
        'rpi4') 
            pacman-key --init
            pacman-key --populate archlinuxarm 
            pacman -Sy archlinux-keyring --noconfirm
            pacman -Syyu --noconfirm
            # Better GPU support out of the box:
        		pacman --remove --recursive --noconfirm linux-aarch64 uboot-raspberrypi
        		pacman -S --needed --noconfirm linux-rpi raspberrypi-firmware raspberrypi-bootloader
        ;;
        'uefi')
            # Pacstrap copies over host (usb) /etc/pacmand.d/mirrorlist
            # -P flag copies over the host /etc/pacman.conf as well.
            pacstrap -P -K /mnt base linux linux-firmware
        ;;
        * ) 
            pacman-key --init
            pacman-key --populate 
            pacman -Sy archlinux-keyring --noconfirm
            pacman -Syyu --noconfirm
        ;;
    esac
}

chroot_mnt() {
    cp /etc/hostname /mnt/etc/hostname
    cp -r /root/evolve /mnt/root/evolve
    arch-chroot /mnt /bin/bash -c "
cd /root/evolve
. ./evolve.env
. ./setup/post-chroot.sh
    "
}

test "$HARDWARE" = "uefi" && prepare_and_mount_partitions 
setup_mirrors
pacman_setup
test "$HARDWARE" = "uefi" && chroot_mnt
. ./setup/post-chroot.sh
