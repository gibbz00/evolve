#!/bin/sh
. ./context.sh

select_device() {
    printf "Take out boot USB/SD-card. When NOT be plugged in; press enter."
    read -r
    # Finding device name
    lsblk > state1.log
    printf "Now insert boot USB/SD-card. When plugged in; press enter."
    read -r
    sleep 1
    lsblk > state2.log
    # Get device name
    device=$(
        grep --invert-match --line-regexp --fixed-strings --file state1.log state2.log \
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
            parted --script --align optimal /dev/"$device" \
                mklabel "msdos" \
                mkpart primary fat32 "1MiB" "1024MiB" \
                set 1 boot on \
                mkpart primary "1024MiB" "100%" \
        ;;
        'uefi')
            parted --script --align optimal /dev/"$device" \
                mklabel "gpt" \
                mkpart liveusb fat32 "0%" "100%" \
        ;;
    esac

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

    _root_directory='root'
    case $HARDWARE in
        'rpi4')
            _boot_directory='boot'
            mkfs.vfat -v /dev/"$1"
            mkdir "$_boot_directory"
            mount /dev/"$1" "$_boot_directory"

            yes | mkfs.ext4 -v /dev/"$2"
            mkdir "$_root_directory"
            mount /dev/"$2" "$_root_directory"
        ;;
        'uefi')
            mkfs.fat -F 32 /dev/"$1"
            mkdir "$_root_directory"
            mount /dev/"$1" "$_root_directory"
        ;;
    esac
}

download_base() {
    case $HARDWARE in
        'rpi4')
            # TEMP: Use torrents instead.
            url='http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz'
            printf "Downloading the latest Arch Linux Arm aarch64 root filesystem from:\n%s\n" $url
            curl --location "$url" \
                bsdtar --verbose --extract --preserve-permissions --file - --directory "$_root_directory"
            sync
            mv "$_root_directory"/boot/* "$_boot_directory"
            # https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4#aarch64installation
            sed --in-place 's/mmcblk0/mmcblk1/g' "$_root_directory"/etc/fstab
            # copy evolve scripts to root
            rsync --recursive --perms --times --verbose --exclude="$_root_directory" --exclude="$_boot_directory" . "$_root_directory"/root/evolve


            sed --expression 's/^#PermitRootLogin.*/PermitRootLogin yes/' --in-place $_root_directory/etc/ssh/sshd_config
            # host name set in preparation step for headless functionality
                # (easer than using nmap and testing to ssh into a bunch random of ip adresses)
            echo "$HOST_NAME" > $_root_directory/etc/hostname
           
            umount "$_boot_directory" "$_root_directory"
            rm --recursive --force "$_boot_directory" "$_root_directory"
        ;;
        'uefi')
            # Following: https://wiki.archlinux.org/title/archiso
            _archiso_profile="install_iso"
            _base_directory="$_archiso_profile/airootfs"
            rsync --recursive --perms --times --verbose --exclude="$_root_directory" --exclude="$_archiso_profile" \
                . "$_base_directory"/root/evolve
            _executables=\
"
setup/
prepare.sh    
utils.sh
"
            for file in $_executables
            do
               sed -i "/file_permissions=(/a [\"/root/evolve/$file\"]=\"0:0:755\"" "$_archiso_profile/profiledef.sh"
            done
            
            # Root password it blank by default on Arch ISOs
            # Something that is not allowed when using SSH
            echo "root:$(openssl passwd -6 $_ssh_initial_root_passwd):14871::::::" > $_base_directory/etc/shadow
            sed --expression 's/^#PermitRootLogin.*/PermitRootLogin yes/' --in-place $_base_directory/etc/ssh/sshd_config
            echo "$HOST_NAME" > $_base_directory/etc/hostname

            # build install_iso
            _work_dir="/tmp/archiso-tmp"
            mkarchiso -v -w "$_work_dir" "$_archiso_profile"
            # https://wiki.archlinux.org/title/archiso#Removal_of_work_directory
            findmnt "$_work_dir" || rm --recursive --force "$_work_dir"

            # archlinux defined in profiledef.sh
            _iso_name="out/archlinux*.iso"
            # shellcheck disable=SC2086
            bsdtar --verbose --extract --preserve-permissions --file $_iso_name --directory "$_root_directory"
            sync
            umount "$_root_directory"
            rm --recursive --force "$_root_directory" out "$_archiso_profile"
        ;;
    esac
}

## Main ##
select_device
partition_device
format_and_mount_partitions
download_base
echo "Preparation complete, boot USB-drive/SD-card can now safely be removed."
