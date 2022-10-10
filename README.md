# Introduction

The goal of this project to serve as a template for personally configured Arch Linux systems work out of the box. 

It's done by scripting the install process into two parts:

* Preparation (prepare.sh) - Preparation of boot and filesystem.
* Setup (setup.sh) - After first standalone boot. User setup, package installations and personal configuartion setup.

Most of the user and system specific configuration that is part of the install process is specified in src/evolve.env. 
Dotfiles are placed in src/skel which then serve as the backbone for the user's homedirectory. 

The project takes a rather different philosophic stance to many of the existing installers.
Config variables assumed to be correctly configured and they give few interactive fail-safes if the opposite is the case.
The benifits gained from this include thinner, readable and customizable scripts, that still provide a high degree of automation. 
Useage should nonethelss be a breeze as long as the steps taken are carefully read and understood.

The setup script can be seen as having two stages: tui and gui.
The gui version builds upon the tui verison.
Meaning that, all packages listed in packages.tui will be included the gui system.
setup.sh will internally source setup.tui.sh no matter what, and then source setup.gui.sh if the variable GUI is set to `true` in evolve.env.

## Supported System Environments

| Base   | Headless (tui) | Desktop (gui) | Hardware       | Alias |
| :---   | :---:          | :---:         | :---:          | :---: | 
| x86_64 | soon           | soon          | TBA            |       | 
| Arm    | x              |               | Raspberry Pi 4 | rpi4  | 
| Docker | soon           |               |                |       | 

## Standard partitions for the given hardware

| Hardware              | Table type   | BOOT              | ROOT                      |
| :---                  | :---:        | :---:             | :---:                     |
| rpi4        | MS-DOS       | 0-1024MiB FAT32   | 1024MiB - Remaining Ext4  |

## evolve.env variables

### Github

It includes the GITHUB_TOKEN that can be set if Github will be used. It's used internally with `gh aut login`, before the autoremoval of evolve.env. The token will in other words not be written in as plain text on the system when the setup has finished. Minimum required scopes for the token are: "repo", "read:org".
 
## Locale

Locales can be a bit tricky. And I've chosen to go the route in which they're defined in .config/locale.conf.
It's exception to the common system setup steps which is not configured in evolve.env. 
A further explanation as for why that is the case can be found in that file.
(src/setup/skel/.config/locale.conf would be the repo path.)

## ARMv8 on Raspberry Pi 4

### Requirements

* An SD-card. Recommended size is at least 8GB. (TUI base install is about 2GB)
* Root access on the preparation machine.
* Internet connection by ethernet. Automated wireless is currently not implemented.
* Dependencies: 
    
    ```
    curl
    lsbl
    dd
    parted
    sshpass
    ```

### Usage

1. Download the necessary scripts.

```
curl --location https://github.com/gibbz00/evolve/archive/development.tar.gz \
    | tar --verbose --extract --preserve-permissions --ungzip --file -
```

2. Configure evolve.env to your liking with your favorite text editor. It will be put into /root during the preparation script, but self-removed by the end of the setup script.

```
cd evolve-development
nvim evolve.env # ;)
```

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
