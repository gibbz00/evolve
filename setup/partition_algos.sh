#!/bin/bash
. ./context.sh

get_storage_devices() {
    _devices=$(lsblk --noheadings --output=NAME --tree | grep -E "^(sd|nvme|mmcblk)\w*")
    _filtered_devices=""
    IFS=$'\n'
    for _device in $_devices
    do
        # Do not include installation medium.
        if ! fdisk -x "/dev/$_device"| grep --quiet --fixed-strings "liveusb"
        then
            _filtered_devices="$_filtered_devices $_device"
        fi
    done
    unset IFS

    echo "$_filtered_devices"
}

get_smallest_storage_device() {
    _names="$1"
    _sizes=''
    for _name in $_names
    do
        _sizes="$_sizes $(lsblk --bytes --noheadings --output=SIZE "/dev/$_name"| head --lines=1)"
    done

    _names_arr=($_names)
    _sizes_arr=($_sizes)

    _min=0
    _min_index=0
    _curr_index=0

    for i in "${_sizes_arr[@]}"; do
        (( i < _min || _min == 0)) && _min=$i && _min_index=$_curr_index
        _curr_index=$((_curr_index + 1))
    done

    echo "${_names_arr[$_min_index]}"
}

get_efi_partition() {
    fdisk -l /dev/"$1" | grep --fixed-strings "EFI System" | grep --only-matching "^/dev/\w*"   
}

get_newest_partition_label() {
    lsblk --noheadings --output NAME --sort NAME \
        | grep "^$1" \
        | grep --invert-match --fixed-string --word-regexp "$1" \
        | tail --line 1   
}

# Gather all storage devices are not mounted and which store at least 20GB.
    # Give them a GPT partition table.
    # Add them to the list of available devices.
# Find the smallest the gathered storage devices
    # (Usually, smaller storage devices tend to be faster.)
    # Make the first 0.5GB of that device the EFI boot partition
    # Set the remaning part of the storage device to be the root partition using the ext4 filesystem.
# For the remaining storage devices.
    # Give them  ext4 partition that spans the entirety of the storage spacet.
    # Mount that partition /dataN where N is the Nth data drive occurence, starting from 0.
linux_only() {
    _physical_devices=$(get_storage_devices)
    _available_devices=""

    for _phy in $_physical_devices
    do
        if ! lsblk --noheadings --output=NAME,MOUNTPOINTS "/dev/$_phy" | grep --quiet --fixed-strings "/"
        then
            _size=$(lsblk "/dev/$_phy" --bytes --noheadings --output SIZE | head --lines=1)
            if test "$_size" -gt "200000000000" # 20 GB
            then
                wipefs --all /dev/"$_phy"
                # Give them a GPT partition table.
                parted --script /dev/"$_phy" mklabel "gpt"
                _available_devices="$_phy $_available_devices"
            fi
        fi
    done

    _smallest_device=$(get_smallest_storage_device "$_available_devices")

    parted --script /dev/"$_smallest_device" \
        mkpart primary fat32 "1MiB" "500MB" \
        set 1 esp on
    partprobe /dev/"$_smallest_device"
    _boot_device_path="/dev/$(get_newest_partition_label "$_smallest_device")"                    
    mkfs.fat -F 32 "$_boot_device_path"

    parted --script /dev/"$_smallest_device" \
        mkpart primary "500MiB" "100%"
    partprobe /dev/"$_smallest_device"
    _root_device_path="/dev/$(get_newest_partition_label "$_smallest_device")"                    
    mkfs.ext4 -v "$_root_device_path"

    # Used for refind-linux.conf
    echo -e "\nROOT_DEVICE=$_root_device_path" >> ./context.sh

    mount "$_root_device_path" /mnt
    mkdir --parents /mnt/boot
    mount "$_boot_device_path" /mnt/boot

    _data_drives_count=0
    for _phy in $_available_devices
    do
        if test "$_phy" != "$_smallest_device"
        then
            parted --script --align optimal /dev/"$_phy" \
                mkpart primary "1MB" "100%"
            partprobe /dev/"$_phy"
            _dev_path="/dev/$(get_newest_partition_label "$_phy")"
            mkfs.ext4 -v "$_dev_path"
            mount --mkdir "$_dev_path" "/mnt/data$_data_drives_count"
            _data_drives_count=$((_data_drives_count + 1))
        fi
    done
}


# Searches each storage device for an unallocated space of at least 10GB
# If found, make a parition out of the remaining space
# Format that partition to ext4
# If the partition is on the same storage device as the EFI system partition, then mount it to /.
# Otherwise mount it to /dataN. (/data0 for the first created partition after /, /data1 for the second and so on.)
windows_preinstalled() {
    _data_drives_count=0
    _physical_devices=$(get_storage_devices)
    for _physical_device in $_physical_devices
    do
        _unallocated_space="$(parted --script /dev/"$_physical_device" \
            print free | \
            grep -E 'GB *Free Space')"
        _unallocated_size="$(echo "$_unallocated_space" | grep --only-matching --perl-regexp '\w*(?=GB\ *Free)')"
        if test "$_unallocated_size" -gt 20
        then
            _start=$(echo "$_unallocated_space" | grep --only-matching -E "^ *\w*" | tr --delete ' ')
            parted --script --align optimal /dev/"$_physical_device" \
                 mkpart primary "$_start" "100%"           
            partprobe /dev/"$_physical_device"
            # Format the newly created partition to ext4
            _new_partition_label=$(get_newest_partition_label "$_physical_device")
            mkfs.ext4 -v /dev/"$_new_partition_label"
            _boot_device_path=$(get_efi_partition "$_physical_device")
            if test "$_boot_device_path"
            then
                mount /dev/"$_new_partition_label" /mnt
                # Used for refind-linux.conf
                echo -e "\nROOT_DEVICE=$_root_device_path" >> ./context.sh
                mount --mkdir "$_boot_device_path" /mnt/boot
            else
                mount --mkdir /dev/"$_new_partition_label" /mnt/data"$_data_drives_count"
                _data_drives_count=$((_data_drives_count + 1))
            fi
        fi
    done
}


