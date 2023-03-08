# Introduction

The goal of this project is to serve as an installation script for personally configured Arch Linux systems to work out of the box. 

It takes a rather different approach to many of the existing installers. The scripts are thin, readable and customizable. And a "pre-configure once", then "install automatically" approach is used. Setup config variables are assumed to be correctly configured for this to work, and this README attemps to make sure that will be the case.

Current support fo the following hadware:

| Base     | Alias | Headless (tui) | Desktop (gui) | Hardware                               |
| :---     | :---: | :---:          | :---:         | :---:                                  |          
| x86_64   | uefi  | WIP            | WIP           | Any UEFI system                        | 
| Arm      | rpi4  | Full           | Full          | The Rasberry Pi 4                      | 
| Docker   |       | TBA            | TBA           |                                        |
| Live USB |       | TBA            | TBA           |                                        |

*Partly because the chosen bootloader does not support legacy BIOS, and partly because newer Windows versions don't work on BIOS systems.

## High-level architecture

The scripted install process is usually divided into two parts:

An installation medium is first prepared from a working *NIX system by running `prepare.sh`.
Once finished, and target machine is and up and running with on it: `setup/ssh.sh` is excuted from the previous system.
It connects to the target via SSH and and runs `setur/main.sh`. This is where users, package, and personal configuartions are installed.
`seput/main.sh` has two stages, TUI and GUI setup. Which stage to use can be configured.
The GUI system is always superset of the TUI verison because it is run after the TUI setup. 

Speaking of configuring. Most of the installation process configuration is specified `src/evolve.env`. All of which are expalained below.
Dotfiles are placed in `src/skel{tui,gui}` which then serve as the backbone for the user's home directory for the respective UIs.
Programs to install in similar fashion placed in `packages/{tui,gui}`.

Out of the box features can be deduced by browsing the config in `skel` and the packages in `packages`.
Features are also added through the install scripts only, here are some:

- Pacman with paralell downloads and color output on by default.
- AUR helper out of the box using `yay`.
- XDG Base Dir Spec adherence: Keeps $HOME clean. Even `.profile` and `.bashrc` is placed in a `.config/bash/`
- Sway with dynamic window transparencies: https://github.com/swaywm/sway/pull/7197
- Sudo without password. Created user is added to the `wheel` group, which then configured to not require password entry on each sudo command.
- For rpi4: Better out of the box integrated GPU support by using the `linux-rpi` kernel with `raspberrypi-firmware` and `raspberrypi-bootloader` over `linux-aarch64` and `uboot-raspberrypi`.
- Bootloader updates when the `refind` package is updated with pacman hooks.
- Console: Supresses info messages popping up in console and adjusts font and size for larger displays to Lat2-Terminus16

# evolve.env variables

### HARDWARE

Required specifying the hardware targets and in turn their special setup commands.

### PARTITION_ALGO

Not used when `$HARDWARE=rpi4`*. It simply uses: MS-DOS partition table, 0-1024MiB FAT32 boot partition, and a 1024MiB to remaining Ext4 root partition.

Partitioning is otherwise tricky to automate since storage layouts come in all shapes and sizes. But this project does allows users the leverage automatic disk partitioning and formating if they so want. If users find the presented partition "algorithms" lacking, there are two choices:

1) Write your own. (PRs are always welcomed :))
2) Skip setting `PARTITION_ALGO` and partition manually **before** running `./setup/ssh.sh`.

Both options must at least result in a GPT partition table with propely sized and formatted root and boot partitions, both mounted to `/mnt` and `/mnt/boot` respectively.

#### PARTITION_ALGO=linux-only

My recommendation. The constraints are for most mininal and those wishing to use a second OS do so with a virtual machine. VMs have come pretty far now days with options such as [Looking Glass](https://looking-glass.io/) offering GPU passthrough. It's what I've been using to access software such as Autodesk's. 


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
    mention _ssh_initial_passwd
$USER_PASSWORD=''
$USERNAME=''

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
 
# Usage

0. Meet the requirements. Other than those listed in the supported hardware and the evolve.env explanation sections, the following will neet to be met:
* Root access on the preparation machine.
* Physical access and a ethernet connecton to the target machine.
* Installation medium with at least 8GB. Any important data backed up as the contets will irrevocaly be wiped from it.
The installation medium is an SD-card on the RPI4 and normally a USB stick in the other cases.
* Special dependencies installed on current system:  `curl`, `parted`, `sshpass`. And for `uefi`: `archiso`

1. Then download the necessary scripts:

```bash
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

2. Configure evolve.env to your liking with your favorite text editor. It will be put into usb stick's /root during the preparation script.

```bash
cd evolve-development
hx evolve.env # ;)
```

3. With the installation medium in hand, run:

```
sudo ./prepare.sh
```

4. Once complete, boot the target from the installation medium.

5. Still from the first computer, and still in `evolve-development/`

```
./setup/ssh.sh
```

And that's it! System should now be fully set up and up and running.

# Limitatons, troubleshooting and TODOS:

* If system time is overcorrected when booting Windows:
Set the time to UTC on Arch [6](https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows). Why? Because [7](https://wiki.archlinux.org/title/System_time#Time_standard

* Automatic setup of a wireless internet connetion when starting the target machine is currently not implemented.

* Have not prioritized exposing a console keymap setting.

* Not supporting proprietary Nvidia GPU drivers. Main reason being poor Wayland compatability and extra hassle of getting them to work properly.

* Swap solution hasn't been implemented yet. Partly because I'm not too keen on using a swap partition. It can't be resiezed and dual boot hibernation is tricky as is. I don't want the partition them to to become an uninteded enabler for it. Going for another route adds a lot of extra complexity with paraemeters that can yeild vastly different result depenting on which hardware is used and for what. So yeah, swap is left on hold for now.
Hopefully it's a non-issue for systems with a decent amount of RAM, and the base template emphasizes a program stack that doen't exessively bloat memory useage.

TODO: add idle usage stats compared with windows 10:
memory,
disk usage,
