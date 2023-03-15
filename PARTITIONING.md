# Partitioning

`HARDWARE=rpi4` simply uses: MS-DOS partition table, 0 - 1024 MiB FAT32 boot partition, and a 1024 MiB to remaining Ext4 root partition.

Partitioning is in other cases tricky to automate since storage layouts come in all shapes and sizes.
This project does nonetheless give users the opportunity do so by setting `PARTITION_ALGO` in `evolve.env`.

### `linux-only`

My recommendation. The constraints are minimal and those wishing to use a second OS do so with a virtual machine. 
The KMS/VFIO/looking-glass/wl-roots projects have come so far these days that it is now possible to dynamically attach a dedicated GPU 
for full GPU pass through to a VM.
Looking glass makes it also possible to show the contents of this VM inside normal application window and with minimal lag.

Anyhow, the partition algorithm for `linux-only` could be stated like this:

```
Gather all storage devices that are able to store at least 20GB and which currently aren't mounted.
  Give them a GPT partition table.
  Add them to the list of available devices.
Find the smallest available device.
  (Usually, smaller storage devices tend to be faster.)
  Use th first 0.5GB of that device for the EFI boot partition
  Set the remaning part of the storage device to be the root partition using the ext4 filesystem.
For the remaining storage devices.
  Give them  ext4 partition that spans the entirety of their storage space.
  Mount that partition /dataN where N is the Nth data drive occurence, starting from 0.
```

 **The partition algorithm will remove anything stored on the storage devices so make sure to move that data somewhere else if needed. 
Install script won't prompt regarding anything about wiping and reformatting partition.**

### `windows-preinstalled`

Given that the following conditions below are met, the installation script *should* work with modern Windows installations:

1) Making sure that the storage device with the Windows install has at least one allocated partition space greater than 20 GB.

2) Each storage device has a GPT partition table already defined.

3) Making sure that only one EFI partition exists, and that it is **at least* 300 MB in size.

4) The Linux kernel won't normally fit in the boot partition because Windows defaults it to 100 MB, far less than the recommended minimum. Workarounds:
[1](https://wiki.archlinux.org/title/Dual_boot_with_Windows#Bootloader_UEFI_vs_BIOS_limitations), 
[2](https://wiki.archlinux.org/title/Dual_boot_with_Windows#UEFI_firmware).
Simply removing some bloat it `/boot/EFI/Microsoft/Boot` won't cut it though.

5) Fastboot/hibernation should be turned off when dualbooting to mitigate the risk of data loss when hibernating one OS and then booting from another.
If some form of hibernation is desired, take the necessary precautions listed at [3](https://wiki.archlinux.org/title/Dual_boot_with_Windows#Fast_Startup_and_hibernation).

6) Turning secure boot off prevents Windows Hello, WSM (Windows Subsystem for Android) and Windows Updates from working on Windows 11.
This limitation could possibly be removed by following the instructions at 
[1](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Booting_an_installation_medium)
and
[2](https://wiki.archlinux.org/title/REFInd#Secure_Boot).

Any who: `windws-preinstalled` uses the something in the lines of following algorithm:

```
For each storage device with an unallocated space of at least 20GB
    Make a partition out of the remaining space
    Format that partition to ext4
    If the partition is on the same storage device as the EFI system partition
        mount it to /
    Otherwise mount it to /dataN, where N is the Nth data drive occurence starting from 0.
```

### `none`

There are others options if users find the existing partition "algorithms" lacking. Here are some:

* Write your own. (PRs are always welcomed :))
* Skip setting `PARTITION_ALGO` and partition manually **before** running `./setup/ssh.sh`.

Both options must at least result in a GPT partition table with properly sized and formatted root and boot partitions, both mounted to `/mnt` and `/mnt/boot` respectively.
The root device appended to written to `context.sh`. Say with `echo -e "\nROOT_DEVICE=$_root_device_path" >> ./context.sh`.
