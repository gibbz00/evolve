# Configuring `evolve.env`

### HARDWARE

$HARWARE: Required specifying the hardware targets and in turn their special setup commands. Match value to alias in TODO: #Supported hardware
$CPU_MANUFACTURER: 'intel' or 'amd'. Used to install and setup the [cpu microcode](https://wiki.archlinux.org/title/Microcode).

### PARTITION_ALGO

Not used when `$HARDWARE=rpi4`*. It simply uses: MS-DOS partition table, 0-1024MiB FAT32 boot partition, and a 1024MiB to remaining Ext4 root partition.

Partitioning is otherwise tricky to automate since storage layouts come in all shapes and sizes. But this project does allows users the leverage automatic disk partitioning and formating if they so want. If users find the presented partition "algorithms" lacking, there are two choices:

1) Write your own. (PRs are always welcomed :))
2) Skip setting `PARTITION_ALGO` and partition manually **before** running `./setup/ssh.sh`.

Both options must at least result in a GPT partition table with propely sized and formatted root and boot partitions, both mounted to `/mnt` and `/mnt/boot` respectively.
The root device appended to written to `context.sh`. Say with `echo -e "\nROOT_DEVICE=$_root_device_path" >> ./context.sh`.

#### PARTITION_ALGO=linux-only

My recommendation. The constraints are for most mininal and those wishing to use a second OS do so with a virtual machine. The KMS/VFIO/looking-glass/wl-roots projects have come so far these days that it is now possible to dynamically attach a dedicated GPU for full pass through between the Linux host and a Windows 10 VM without restarting Sway. Looking glass makes it also possible to show the contents of this VM inside normal application window.

The partition algorithm for `linux-only` is something like this:

```
Gather all storage devices are not mounted and which store at least 20GB.
  Give them a GPT partition table.
  Add them to the list of available devices.
Find the smallest the gathered storage devices
  (Usually, smaller storage devices tend to be faster.)
  Make the first 0.5GB of that device the EFI boot partition
  Set the remaning part of the storage device to be the root partition using the ext4 filesystem.
For the remaining storage devices.
  Give them  ext4 partition that spans the entirety of the storage spacet.
  Mount that partition /dataN where N is the Nth data drive occurence, starting from 0.
```

This will remove anything stored on the storage devices so make sure to move that data somewhere else if needed.
If using drives with pre-existing partition tables, use `wipefs --all <device_path>` on each target devices to avoid the "are you sure".

#### PARTITION_ALGO=windows-preinstalled

Given that the the following conditions below are, the installation script should work with moders Windows installations:

1) Making sure that the storage device with the Windows install has at least one allocated partition space greater than 20GB.
2) Each storage device has a GPT partition table already defined.
3) Making sure that only one EFI partition exists, and that it is at least 300MB in size.

The Linux kernel won't normally fit in the boot partition because Windows defaults it to 100MB, far less then the recommended minimum. 
There are some workarounds:
[1](https://wiki.archlinux.org/title/Dual_boot_with_Windows#Bootloader_UEFI_vs_BIOS_limitations), 
[2](https://wiki.archlinux.org/title/Dual_boot_with_Windows#UEFI_firmware).

Simply removing some bloat it `/boot/EFI/Microsoft/Boot` won't cut it though.

4) Fastboot/hibernation should be turned off on both OSs when dualbooting to mitigate the risk of data loss when hibernating one OS and then booting from another. If some form of hibernation is desired, take the necessary precations listed at [3](https://wiki.archlinux.org/title/Dual_boot_with_Windows#Fast_Startup_and_hibernation).

5) Secure boot will be turned off. Doing so prevents Windows Hello, WSM (Windows Subsystem for Android) and Windows Updates from working on Windows 11.
This limitation could possibly be removed by following the instructions at 
[4](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Booting_an_installation_medium)
and
[5](https://wiki.archlinux.org/title/REFInd#Secure_Boot).

Anywho: `windws-preinstalled` uses the following algorithm:

```
For each storage device with an unallocated space of at least 20GB
    Make a partition out of the remaining space
    Format that partition to ext4
    If the partition is on the same storage device as the EFI system partition
        mount it to /
    Otherwise mount it to /dataN, where N is the Nth data drive occurence starting from 0
    (/data0 for the first created partition after /, /data1 for the second and so on.)
```

### USER, ROOT and HOST setup
$HOST_NAME
$ROOT_PASSWORD
$USER_PASSWORD=''
$USERNAME=''

The installation script makes that the entiry evolve directory is removed upon successful install, both on target machine and on installation medium. 
By then it will also remove the the plain-text passwords and the Git Hub token from `evolve.env` on the preparation machine.

$SSH_SERVER=true/false

Will install `openssh` and enable the ssh deamon on the target device if set to true.
This currently happens regardless when `HARDWARE=rpi4`

### Locale

$COUNTRY='SE'
$TIMEZONE='Europe/Stockholm'
Locales can be a bit tricky.
And I've chosen to go the route in which they're defined in .config/locale.conf.
It's exception to the common system setup steps which is not configured in evolve.env. 
A further explanation as for why that is the case can be found in that file.
(src/setup/skel/.config/locale.conf would be the repo path.)

### UI

    $GUI=false

### Keyboard

    $SWAP_CAPS_ESCAPE=false
    $SWAP_LCTRL_LALT=false

    Mention that GUI layouts are set in sway config.

### Git

$GIT_USERNAME=''
$GIT_EMAIL_ADRESSS=''
$GITHUB_TOKEN='XXXX'

If Github will be used. It's used internally with `gh auth login`, before the autoremoval of evolve.env.
The token will in other words not be written as plain text once the setup has finished. 
Minimum required scopes for the provided token are: "repo", "read:org".

### Rust

RUST_TOOLCHAIN='' # stable/nightly/version or none

If set; installs rustup as an [arch linux package](https://wiki.archlinux.org/title/Rust#Arch_Linux_package) and installs the given toolchain to be used as a default.
Additional toolchains can always be installed with `rustup toolchain install <toolchain>`.)
The LSP server for rust (`rust-analyzer`) is opitonally added by listing it in `packages`.
