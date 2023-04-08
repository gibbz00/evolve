# Introduction

The goal of this project is to serve as an installation script for personally configured Arch Linux systems to work out of the box. 

It takes a rather different approach to many of the existing installers. The scripts are thin, readable and customizable. And a "pre-configure once", then "install automatically" approach is used. Setup config variables are assumed to be correctly configured for this to work, and this README attempts to make sure that will be the case.

Hardware configuration support:

| Base     | Alias | Headless (TUI) | Desktop (GUI) | Hardware                               |
| :---     | :---: | :---:          | :---:         | :---:                                  |          
| x86_64   | uefi  | Full           | Full          | Any UEFI system*                       | 
| Arm      | m1    | Full           | Full          | Mac Mini 2020 (M1)                     | 
| Arm      | rpi4  | Full           | Full          | The Rasberry Pi 4                      | 
| Docker   |       | TBA            | TBA           |                                        |
| Live USB |       | TBA            | TBA           |                                        |

*Partly because the chosen bootloader does not support legacy BIOS, and partly because newer Windows versions don't work on BIOS systems.

Check out [ARCHITECTURE.md](ARCHITECTURE.md) for a high level introduction to how it all works, and [CONFIGURING.md](CONFIGURING.md) for an explanation on how to configure `evolve.env`.
 
# Usage

(For the M1; see [#M1 Installation].)

0. Other than those listed in the supported hardware and the `evolve.env` explanation sections, the following needs to be met:
* Root access on the preparation machine.
* Physical access and an Ethernet connection to the target machine.
* Installation medium with at least 8 GB. Any important data backed up as the contents will irrevocably be wiped from it.
The installation medium is an SD-card on the RPI4 and normally a USB stick in the other cases.
* Special dependencies installed on current system: `curl`, `parted`, `sshpass`. And for `uefi`: `archiso`

1. Then download the necessary scripts:

```bash
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

2. Configure `evolve.env` to your liking with your favorite text editor. It will be put into USB stick's /root during the preparation script.

3. With the installation medium in hand, run:

```bash
sudo ./prepare.sh
```

4. Once complete, boot the target from the installation medium.

5. Still from the first computer, and still in `evolve-development/`

```bash
./setup/ssh.sh
```

And that's it! System should now be fully set up and up and running.

## M1 Installation

1. Carefully read up on the requirements and expectations at: [Asahi Linux Feature Support](https://github.com/AsahiLinux/docs/wiki/Feature-Support) and [Alpha installer](https://asahilinux.org/2022/03/asahi-linux-alpha-release/). Then begin the **minimal arch** installation process with:

```bash
  curl https://alx.sh | sh  
```

2. Log in with `root` pass=`root` once installed.

3. Curl the project:

```bash
# in /root
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

4. Edit `evolve.env` to your liking but with `HARDWARE='m1'`.

5. And then finally: 

```bash
./setup/tui.sh
```

# Limitations, troubleshooting and TODOS:

* If system time is overcorrected when booting Windows:
Set the time to UTC on Arch [6](https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows). Why? Because [7](https://wiki.archlinux.org/title/System_time#Time_standard)

* Automatic setup of a wireless internet connection when starting the target machine is currently not implemented.

* Have not prioritized exposing a console keymap setting.

* Not supporting proprietary Nvidia GPU drivers. Main reason being poor Wayland compatibility and extra hassle of getting them to work properly.

* Swap solution hasn't been implemented yet. Partly because I'm not too keen on using a swap partition. It can't be resized, and dual boot hibernation is tricky as is. I don't want the partition them to become an unintended enabler for it. Going for another route adds a lot of extra complexity with parameters that can yield vastly different result depending on which hardware is used and for what. So yeah, swap is left on hold for now.
Hopefully it's a non-issue for systems with a decent amount of RAM, and the base template emphasizes a program stack that doesn't excessively bloat memory usage.

TODO: add idle usage stats compared with Windows 10:
memory,
disk usage,
