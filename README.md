# Introduction

The goal of this project is to serve as an installation script for personally configured Arch Linux systems to work out of the box. 

It takes a rather different approach to many of the existing installers. The scripts are thin, readable and customizable. And a "pre-configure once", then "install automatically" approach is used. Setup config variables are assumed to be correctly configured for this to work, and this README attemps to make sure that will be the case.

Current support of the following hadware:

| Base     | Alias | Headless (tui) | Desktop (gui) | Hardware                               |
| :---     | :---: | :---:          | :---:         | :---:                                  |          
| x86_64   | uefi  | Full           | Full          | Any UEFI system*                       | 
| Arm      | rpi4  | Full           | Full          | The Rasberry Pi 4                      | 
| Docker   |       | TBA            | TBA           |                                        |
| Live USB |       | TBA            | TBA           |                                        |

*Partly because the chosen bootloader does not support legacy BIOS, and partly because newer Windows versions don't work on BIOS systems.

## High-level architecture

The scripted install process is usually divided into two parts:

An installation medium is first prepared from a working *NIX system with bash by running `prepare.sh`.
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
- AUR helper out of the box using `paru`.
- XDG Base Dir Spec adherence: Keeps $HOME clean. Even `.profile` and `.bashrc` is placed in a `.config/bash/`
- Sway with dynamic window transparencies: https://github.com/swaywm/sway/pull/7197
- Sudo without password. Created user is added to the `wheel` group, which then configured to not require password entry on each sudo command.
- For rpi4: Better out of the box integrated GPU support by using the `linux-rpi` kernel with `raspberrypi-firmware` and `raspberrypi-bootloader` over `linux-aarch64` and `uboot-raspberrypi`.
- Bootloader updates when the `refind` package is updated with pacman hooks.
- Console: Supresses info messages popping up in console and adjusts font and size for larger displays to Lat2-Terminus16
 
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
