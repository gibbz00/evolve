# Overview

## Background

The goal of this project is to automate setup of my personally configured Arch Linux systems.
All configurations and programs should work out of the box.

### System Environments

| Base   | Headless (tui) | Desktop (gui) | Hardware                                |
| :---   | :---:          | :---:         | :---:                                   |
| x86_64 | soon           | soon          | Xiaomi Notebook Pro, QNAP TS-259 Pro+   |
| Arm    | x              |               | Raspberry Pi 4                          | 
| Docker | soon           |               |                                         |

### Standard partitions

| Hardware              | Table type   | BOOT              | ROOT                      |
| :---                  | :---:        | :---:             | :---:                     |
| raspberry_pi_4        | MS-DOS       | 0-1024MiB FAT32   | 1024MiB - Remaining Ext4  |


### Architecture

The automation is divided into two parts. The role taken by the parts differ depending on the chosen base or hardware configuration. E.g A Dockerfile can handle all tasks from the respective stages and must therefore only have one. Anyway, here's the general role of each part.

* Preparation (prepare.sh) - Preparation of boot and filesystem.
* Setup (setup.sh) - After first standalone boot. User setup, package installations and personal configuartion setup.

### Features

# Usage

All commands beginning with a `$` should be run unpriviliged and all commands beginning with a `#` should be run as root.
 
## Arm on Raspberry Pi 4

### Requirements

* An SD-card (recommended size is at least 8GB)
* A decent CLI interface in a mostly POSIX compliant environment. Most Linux distros work for sure (WSL too). BSDs, macOS should be fine, but don't quote me on that.
    * Dependencies: 
    `
        curl
        lsblk
        dd
        parted
    `
* Root access on the preparation machine.
* Ethernet cable internet connection to the Raspberry Pi 4 is going for the headless install.

### Preparation

1. Download the necessary scripts.

`$ curl --location https://www.github.com/gibbz00/evolve/archive/development.tar.gz | tar --extract --preserve-permissions --file - --directory evolve`

2. Edit evolve.env to your liking with your favorite text editor. It will be put into /root during the preparation script, but self-removed by the end of the setup script. 

`$ nvim evolve/setup/evolve.env # ;)`

3. Have the SD-card in hand and run the preparation script. **Backup any important data on the SD-card before proceeding. All data will be irrevocaly wiped.**

`$ cd evolve/prepare`
`# ./prepare.sh -h raspberry_pi_4`

### Setup

0. If connecting through SSH. 


`
    # ssh root@$HOSTNAME
    $ ssh root@evolve-raspberry_pi_4
`

Then skip to step 2. 

1. Make sure that an internet connection is set up.

`$ ping -c 3 google.com`

I would recommend `wifi-menu` for setting up wireless networks, mostly for it's ease of use.

4. Run setup script.

`$ cd /root/evolve/setup`
`$ sh ./setup.sh`
