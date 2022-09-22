# Overview

## Background

The goal of this project is to automate setup of my personally configured Arch Linux systems.
All configurations and programs should work out of the box.

### System Environments

| Base   | Headless (tui) | Desktop (gui) | Hardware                                | 
| :---   | :---:          | :---:         | :---:                                   | 
| x86_64 | x              | x             | Xiaomi Notebook Pro, QNAP TS-259 Pro+   |
| Arm    | x              |               | Raspberry Pi 4                          |
| Docker | x              |               |                                         |

### Architecture

The automation is divided into three parts. The role taken of the differenc parts differ depending on the chosen base. E.g A Dockerfile can handle all tasks from the respective stages and must therefore only have one. Anyway, here's the general role of each part.

* Preparation (prepare.sh) - Preparing boot medium.
* Install (install.sh) - Partitioning, installing bootloader. 
* Setup (setup.sh) - User setup, install all the applications and personal configuartions.

### Features

# Usage
 
## Arm on Raspberry Pi 4

### Requirements

* An SD-card (recommended size is at least 8GB)
* A decent CLI interface in a mostly POSIX compliant environment. macOS and most Linux distros (in WSL too) should be fine. But don't quote me on that.
* Root access

### Preparation

1. Have a SD-card in hand and run the preparation script.

`./prepare.sh`

### Setup

1. Make sure that an internet conneciton is set up.

`$ ping -c 1 google.com`

I would recommend `wifi-menu` for setting up wireless networks, mostly for it's ease of use.

2. Download the setup scripts and their helper files

`$ curl --location <url>/evolve.zip | zip -d evolve`

3. Make the scripts executable. 

`$ cd evolve`
`$ chmod +x setup.*.sh`

4. Edit setup.env to your liking with your favorite text editor

`$ nvim setup.env # ;)`

5. Run setup scripts. *.gui is a extension of *.tui. GUI systems must in other words run both setup scripts.  

TUI (headless) only: 

`# In evolve/`
`$ sh ./evolve/setup.tui.sh`

GUI:

`# In evolve/`
`$ sh ./evolve/setup.tui.sh`
`$ sh ./evolve/setup.gui.sh`
