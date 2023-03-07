# Introduction

The goal of this project to serve as a template for personally configured Arch Linux systems work out of the box. 

The project takes a rather different philosophic stance to many of the existing installers.
Well documented config variables assumed to be correctly configured and they give few interactive fail-safes if the opposite is the case.
The benifits gained from this include thinner, readable and customizable scripts, that still provide a high degree of automation. 

### High-level architecture

The scripted install process is usually devided into two parts:

1) Preparation with `prepare.sh` of the installation medium on working currently Linux system.
2) Once the boot installation medium is plugged into the target machine and up and running; `setup/ssh.sh` is excuted from the previous system.
It sources `setup.sh` on the target machine that then sets up users, package installations and personal configuartions.

The local setup can be seen as having two stages: TUI and GUI.
The GUI version is always superset of the TUI verison.
Or in other words, all packages TUI packaeges and configurations are also included in the GUI system.

#### File architecture

Most of the user and system specific configuration that is part of the install process is specified in `src/evolve.env`. 
Dotfiles are placed in `src/skel` which then serve as the backbone for the user's home directory. 
`setup.sh` will internally source `setup.tui.sh`.
If the GUI is set to `true` in evolve.env; then `setup.gui.sh` is also sourced.

## General Features

Programs used can be checked out by browsing `packages/{tui,gui}` with the respective configs in:
`skel/`. Some features are added through the install scrpits:

- Sudo: users in wheel group need not type their password on each sudo command. Created user is also added to this group.
- Pacman: Paralell downloads and color output on by default.
- AUR: Helper out of the box using `yay`.
- Console: Supresses info messages popping up in console and adjusts font and size for larger displays to Lat2-Terminus16
- XDG Base Dir Spec adherence: Keeps $HOME clean. Even `.profile` and `.bashrc` is placed in a `.config/bash/`
- Bootloader: Refind that gets automatically updates when the `refind` package is updated by using pacman hooks.
- Sway with dynamic window transparencies: https://github.com/swaywm/sway/pull/7197
- rpi4: Better out of the box integrated GPU support by using the `linux-rpi` kernel with `raspberrypi-firmware` and `raspberrypi-bootloader` over `linux-aarch64` and `uboot-raspberrypi`.

# evolve.env variables

### Hardware

An alias for specifying the hardware targets and in turn their special setup commands.
Supported targets that this project currently supports:

| Alias | Base   | Headless (tui) | Desktop (gui) |
| :---: | :---   | :---:          | :---:         |
| wrk   | x86_64 | WIP            | WIP           | 
| rpi4  | Arm    | x              | x             | 
| wsl   | WSL    | WIP            |               |
|       | Docker | WIP            |               |

Footnotes for 'wrk':
UEFI boot only; supporting Windows 11 dualbooting is prioritized over legacy BIOS booting.
Not supporting proprietary Nvidia GPU drivers. Main reason being poor Wayland compatability and extra hassle of getting them to work properly.
Fast Startup and hibernation disabled due to prioritized dualboot support.

### Standard partitions for the given hardware

#### rpi4 (Raspberry Pi 4)
Table type: MS-DOS

**SD Card:**
BOOT: 0-1024MiB FAT32
ROOT: 1024MiB - Remaining Ext4

#### wrk (workstation)

Partitions are prepared from Windows to then imply how the partitioning is to be automatically setup during the Linux installation.
The installation script will then crate partitions with the following algorithm, (so prepare the disk partitions accordinly in Disk Management utility in Windows):

```
For each storage device with an unallocated space of at least 20GB
    Make a partition out of the remaining space
    Format that partition to ext4
    If the partition is on the same storage device as the EFI system partition
        mount it to /
    Otherwise mount it to /dataN, where N is the Nth data drive occurence starting from 0
    (/data0 for the first created partition after /, /data1 for the second and so on.)
```

So in other words: A minumum requirement is making sure that the storage device with the Windows install has at least of free unallocated partition space.
Check also that only only EFI partition exists!

### Github

It includes the GITHUB_TOKEN that can be set if Github will be used.
It's used internally with `gh auth login`, before the autoremoval of evolve.env.
The token will in other words not be written as plain text once the setup is finished. 
Minimum required scopes for the provided token are: "repo", "read:org".
 
### Locale

Locales can be a bit tricky.
And I've chosen to go the route in which they're defined in .config/locale.conf.
It's exception to the common system setup steps which is not configured in evolve.env. 
A further explanation as for why that is the case can be found in that file.
(src/setup/skel/.config/locale.conf would be the repo path.)


# Usage

## Workstation

### Requirements

* A x86_64 machine with UEFI support with Windows already installed (target).  Should be using a GPT partition table.
(EFI system partition created by Windows will be reused.)
* USB stick with at least XX GB.
* Internet connection by ethernet on the target machine. Wireless install is currently not implemented.
* Special dependencies:  `curl`, `parted`, `sshpass`, `archiso`

### Usage

1. Download the necessary scripts.

```bash
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

2. Configure evolve.env to your liking with your favorite text editor. It will be put into usb stick's /root during the preparation script.

```bash
cd evolve-development
hx evolve.env # ;)
```

Most important requirement is setting `HARDWARE = wrk`.

3. Have the USB-device in hand and run the preparation script. **Backup any important data on the USB-device before proceeding. All data will irrevocaly be wiped.**

```
sudo ./prepare.sh
```

4. Preparing the Windows installation: 
- Make sure that Secure Boot is turned **off**. 
    * Secure boot must be disabled to boot Arch an installation medium.
    On Windows 11, disabling Secure Boot prevents Windows Hello, WSM (Windows Subsystem for Android) and Windows Updates from working.
    This limitation could possibly be removed by following the instructions at: 
    https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Booting_an_installation_medium
    and https://wiki.archlinux.org/title/REFInd#Secure_Boot
- Make sure that Fast Startup and Hibernation is disabled:
    Windows 8: https://www.eightforums.com/threads/fast-startup-turn-on-or-off-in-windows-8.6320/
    Windows 10: https://www.tenforums.com/tutorials/4189-turn-off-fast-startup-windows-10-a.html
    Windows 11: https://www.elevenforum.com/t/turn-on-or-off-fast-startup-in-windows-11.1212/
    * Why: Risk of data loss when hibernating one OS and then booting from another. For more information:
    https://wiki.archlinux.org/title/Dual_boot_with_Windows#Fast_Startup_and_hibernation
- Make sure the disks are prepared to be partitionened:
    * See: #TODO link for more information on how partitioning can be designed.

5. The boot the target from the USB-stick. Once complete, from the first computer:

```
# still in evolve-development/
./setup/ssh.sh
```

And that's it! System should now be fully set up. Last step now is to eject the USB stick and reboot the target.

## WSL

Makes use of ArchWSL: https://github.com/yuk7/ArchWSL#archwsl

### Requirements

* WSL2 cabable computer with Administator access. I.e a x86_64 (x64) system with Windows 10 version 1903 or later.

### Usage

1. Open Powershell as Admininstator and download the necessary scripts.

```bash
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```


2. Configure evolve.env to your liking with your favorite text editor. It will be put into /root during the preparation script, but self-removed by the end of the setup script.

```bash
cd evolve-development
hx evolve.env # ;)
```

Only requirement is setting `HARDWARE = wsl`.

3. Now run prepare.cmd

```
prepare.cmd
```

## ARMv8 on Raspberry Pi 4 (rpi4)

### Requirements

* An SD-card. Recommended size is at least 8GB. (TUI base install is about 2GB)
* Root access on the preparation machine.
* Internet connection by ethernet. Wireless install is currently not implemented.
* Special dependencies:  `curl`, `parted`, `sshpass`.

### Usage

1. Download the necessary scripts.

```bash
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

2. Configure evolve.env to your liking with your favorite text editor. It will be put into /root during the preparation script, but self-removed by the end of the setup script.

```bash
cd evolve-development
hx evolve.env # ;)
```

Only requirement is setting `HARDWARE = rpi4`.

3. Have the SD-card in hand and run the preparation script. **Backup any important data on the SD-card before proceeding. All data will irrevocaly be wiped.**

```
sudo ./prepare.sh
```

4. Insert the SD into the Raspberry Pi 4 and power it up.

5. Still from the first computer:

```
# in evolve-development/
./setup/ssh.sh
```
And that's it! System should now be up and running :)

# Limitations and troubleshooting:

### wrk

* Multiple kernel support out of the box is limited but can be worked around:
https://wiki.archlinux.org/title/Dual_boot_with_Windows#Bootloader_UEFI_vs_BIOS_limitations

* If system time is overcorrected when booting on Windows:
Set the time to UTC: https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows
Why: https://wiki.archlinux.org/title/System_time#Time_standard

### General

* Have not prioritised a swap solution.
And I have am not using swap partitions because:
    1) Hibernation is tricky as is with dualboot and I don't want swap partition to become an unadviced enabler.
    2) Extra complexity in the installation script.
    3) Inability for the partition to trivially be resized.
A decent amount of RAM is instead assumed with a base system that puts careful consideration into using a program stack that does not bloat memory.
TODO: add idle usage stats compared with windows 10.

* Have not prioritized exposing a console keymap setting.

