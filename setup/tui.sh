#!/bin/bash
. ./utils.sh

# Searches each storage device for an unallocated space of at least 10GB
# If found, make a parition out of the remaining space
# Format that partition to ext4
# If the partition is on the same storage device as the EFI system partition, then mount it to /.
# Otherwise mount it to /dataN. (/data0 for the first created partition after /, /data1 for the second and so on.)
prepare_and_mount_partitions() {
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
                mount --mkdir /dev/"$_new_partition_label" "/mnt/data$_data_drives_count"
                _data_drives_count=$((_data_drives_count + 1))
            fi
        fi
    done

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
        'wrk')
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
    arch-chroot /mnt
    cd /root
    . "./evolve.env"
}

clock_setup() {
    # Network time syncronization
    ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    # Raspberry Pi 4 does not include an on-board hardware clock
    if test "$HARDWARE" != 'rpi4'
    then
        hwclock --systohc
    else 
        # But because it is not booted under chroot, it can on the other hand be configured to use the Network Time Protocol here.
        # (timedatectl requires an active D-Bus, which isn't present in chroot.)
        timedatectl set-ntp true
    fi
}

localization_setup() {(
    # Extract mentioned locales 
    locales=$(grep --only-matching --perl-regexp "(?<==)\S*" skel/tui/.config/locale.conf | uniq)
    for locale in $locales
    do
        uncomment_util "$locale UTF-8" /etc/locale.gen
    done
    # Generate locales
    locale-gen
    # For changes to take an immediate effect
    . skel/tui/.config/locale.conf
)}

# Setup before yay since makepkg can't be run as root
user_setup() {(
    printf "%s\n%s" "$ROOT_PASSWORD" "$ROOT_PASSWORD" | passwd

    mkdir merged-skel
    # || true to supress output 
    # wilcard (*) doesn't match hidden files by default
    cp -r skel/tui/{*,.[!.]*} merged-skel 2>/dev/null || true 
    $GUI && cp -r skel/gui/{*,.[!.]*} merged-skel 2>/dev/null || true 

    useradd --skel merged-skel --create-home --shell /bin/bash --groups users,wheel "$USERNAME"
    printf "%s\n%s" "$USER_PASSWORD" "$USER_PASSWORD" | passwd "$USERNAME"

    if test "$HARDWARE" = 'rpi4'
    then
        # remove default alarm user
        userdel --remove alarm
    fi
)}

yay_setup() {
    pacman -S git base-devel sudo --needed --noconfirm 
    uncomment_util ' %wheel ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers
    sudo -u "$USERNAME" sh -c "
        cd /home/$USERNAME 
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg --syncdeps --install --noconfirm --needed
        cd .. && rm --recursive --force yay-bin
    "
}

bash_force_xdg_base_spec() {
    # Appended to /etc/profile rather then added to /etc/profile.d to ensure
    # that everything in profile.d/ (e.g locale.sh) is sourced first. 
    cat sys/bash_login_xdg.sh >> /etc/profile
    # bashrc.d not included by default in Arch Linux distro
    mkdir --parent /etc/bashrc.d
    cp sys/bash_interactive_xdg.sh /etc/bashrc.d/
    code="
# Load run commmands from /etc/bashrc.d
if [ -d /etc/bashrc.d/ ]; then
    for file in /etc/bashrc.d/*.sh; do
        [ -r \"\$file\" ] && . \"\$file\" 
    done
    unset file
fi"
    echo "$code" >> '/etc/bash.bashrc'
}

swap_keys_option() {
    ($SWAP_CAPS_ESCAPE || $SWAP_LCTRL_LALT) || return 0
    
    $SWAP_CAPS_ESCAPE && cp sys/90-swap-caps-escape.hwdb /etc/udev/hwdb.d/
    $SWAP_LCTRL_LALT && cp sys/90-swap-lctrl-lalt.hwdb /etc/udev/hwdb.d/

    # TODO: works in chroot?
    systemd-hwdb update
    udevadm trigger
}

install_bootloader() {
    mkdir /boot/EFI    
    pacman -S refind --needed --noconfirm 
    refind-install --root /boot
    cp evolve/sys/refind.hook /etc/pacman.d/hooks/
}

misc_setup() {(
    # Supress some error messages in console
    cp sys/20-quiet-printk.conf /etc/sysctl.d/

    # Consolefont setting
    cp sys/vconsole.conf /etc/
    # Make changes immediate
    test "$HARDWARE" = "rpi4" && systemctl restart systemd-vconsole-setup

    # Git
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL_ADRESSS"
    git config --global advice.addIgnoredFile false

    # Github
    if test -n "$GITHUB_TOKEN"
    then
        # HACK: creation of gitconfig doesn't respect .config of XDG_CONFIG_HOME as of 2022-09-28
        #   better to solve issue upstream rather removing .config hardcode
        sudo -u "$USERNAME" sh -c "
	    yay -S --noconfirm --needed github-cli
            echo $GITHUB_TOKEN | gh auth login --with-token 
	    cd /home/$USERNAME
            gh auth setup-git
            mkdir --parent ~/.config/git
            mv .gitconfig ~/.config/git/config
        "
    fi
)}

test "$HARDWARE" = "wrk" && prepare_and_mount_partitions
setup_mirrors
pacman_setup
test "$HARDWARE" = "wrk" && chroot_mnt
clock_setup
localization_setup
user_setup
yay_setup
install_packages_util "packages/tui"
bash_force_xdg_base_spec
swap_keys_option
test "$HARDWARE" = "wrk" && install_bootloader
misc_setup
