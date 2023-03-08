linux-only() {
    
}

# Searches each storage device for an unallocated space of at least 10GB
# If found, make a parition out of the remaining space
# Format that partition to ext4
# If the partition is on the same storage device as the EFI system partition, then mount it to /.
# Otherwise mount it to /dataN. (/data0 for the first created partition after /, /data1 for the second and so on.)
windows-preinstalled() {
    _data_drives_count=0
    _physical_devices=$(lsblk --noheadings --output NAME --tree | grep -E "^(sd|nvme|mmcblk)\w*")
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
            _new_partition_label=$(lsblk --noheadings --output NAME --sort NAME \
                    | grep "^$_physical_device" \
                    | grep --invert-match --fixed-string --word-regexp "$_physical_device" \
                    | tail --line 1)
            mkfs.ext4 -v /dev/"$_new_partition_label"
            # Check which new partition had the EFI partition on the same device.
            # (Using fdisk as it prints the full device path)
            _boot_device_path=$(fdisk -l /dev/"$_physical_device" | grep --fixed-strings "EFI System" | grep --only-matching "^/dev/\w*")
            if test "$_boot_device_path"
            then
                mount /dev/"$_new_partition_label" /mnt
                mount --mkdir "$_boot_device_path" /mnt/boot
            else
                mount --mkdir /dev/"$_new_partition_label" /mnt/data"$_data_drives_count"
                _data_drives_count=$((_data_drives_count + 1))
            fi
        fi
    done
}
