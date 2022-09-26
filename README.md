# Description

The goal of this project is to automate setup of my personally configured Arch Linux systems. It aims to make all configurations and programs work out of the box and ready for development.

The automation is divided into two parts. The role taken by the parts differ depending on the chosen base or hardware configuration. E.g. a Dockerfile can handle all tasks from the respective stages and must therefore only have one. Anyway, here's the general role of each part.

* Preparation (prepare.sh) - Preparation of boot and filesystem.
* Setup (setup.sh) - After first standalone boot. User setup, package installations and personal configuartion setup.

## System Environments

| Base   | Headless (tui) | Desktop (gui) | Hardware                                |
| :---   | :---:          | :---:         | :---:                                   |
| x86_64 | soon           | soon          | Xiaomi Notebook Pro, QNAP TS-259 Pro+   |
| Arm    | x              |               | Raspberry Pi 4                          | 
| Docker | soon           |               |                                         |

## Standard partitions

| Hardware              | Table type   | BOOT              | ROOT                      |
| :---                  | :---:        | :---:             | :---:                     |
| raspberry_pi_4        | MS-DOS       | 0-1024MiB FAT32   | 1024MiB - Remaining Ext4  |

# Usage

All commands beginning with a `$` should be run unpriviliged and all commands beginning with a `#` should be run as root.

## evolve.env

Most of the user/system system specific configuration is done in src/evolve.env, which is then used by prepare.sh and setup.sh.

### Github

It includes the`GITHUB_TOKEN` that can be set if Github will be used. It's used internally with `gh aut login`, before the autoremoval of evolve.env. The token will in other words not be written in as plain text on the system when the setup has finished. Minimum required scopes for the token are: "repo", "read:org".
 
## Locale

Locales can be a bit tricky. And I've chosen to go the route in which they're defined in `.config/locale.conf`.
It's exception to the common system setup steps which is not configured in evolve.env. 
A further explanation as for why that is the case can be found in that file, it's also where a short explanation is given as to how locale can be configured.
(`src/setup/skel/.config/locale.conf` would be the repo path.)

## ARMv8 on Raspberry Pi 4

### Requirements

* An SD-card (recommended size is at least 8GB)
* Root access on the preparation machine.
* Ethernet cable internet connection to the Raspberry Pi 4 is going for the headless install.
* Dependencies: 
    
    ```
    curl
    lsblk
    dd
    parted
    ```

### Preparation

1. Download the necessary scripts.

```
$ curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

2. Edit evolve.env to your liking with your favorite text editor. It will be put into /root during the preparation script, but self-removed by the end of the setup script.

```
$ cd evolve-development/src
$ nvim evolve.env # ;)
```


3. Have the SD-card in hand and run the preparation script. **Backup any important data on the SD-card before proceeding. All data will irrevocaly be wiped.**

```
# ./prepare.sh
```

### Setup

1. Insert the SD into the Raspberry Pi 4 and power it up.

2. If connecting through SSH:

```
$ ssh root@evolve-raspberry_pi_4 #root@$HOSTNAME
```

Password is root. This is then interactively set to something else during the setup script.

Then skip to step 4.

3. Make sure that an internet connection is set up.

```
$ ping -c 3 google.com
```

I would recommend `wifi-menu` for setting up wireless networks, mostly for it's ease of use.

4. Finally, run setup script.

```
$ cd /root/evolve/setup
$ sh ./setup.sh
```
