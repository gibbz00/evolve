# Architecture

The scripted install process is usually divided into two parts:

An installation medium is first prepared from a working *NIX system with bash by running `prepare.sh`.
Once finished, and target machine is and up and running with on it: `setup/ssh.sh` is executed from the previous system.
It connects to the target via SSH and and runs `setur/main.sh`. This is where users, package, and personal configurations are installed.
`seput/main.sh` has two stages, TUI and GUI setup. Which stage to use can be configured.
The GUI system is always superset of the TUI version because it is run after the TUI setup. 

Speaking of configuring. Most of the installation process configuration is specified `src/evolve.env`. All of which are explained below.
Dotfiles are placed in `src/skel{tui,gui}` which then serve as the backbone for the user's home directory for the respective UIs.
Programs to install in similar fashion placed in `packages/{tui,gui}`.

Out of the box features can be deduced by browsing the config in `skel` and the packages in `packages`.
Features are also added through the installation scripts only, here are some:

- Pacman with parallel downloads and color output on by default.
- AUR helper out of the box using `paru`.
- XDG Base Dir Spec adherence: Keeps $HOME clean. Even `.profile` and `.bashrc` is placed in a `.config/bash/`
- Sway with dynamic window transparencies: https://github.com/swaywm/sway/pull/7197
- Sudo without password. Created user is added to the `wheel` group, which then configured to not require password entry on each sudo command.
- For rpi4: Better out of the box integrated GPU support by using the `linux-rpi` kernel with `raspberrypi-firmware` and `raspberrypi-bootloader` over `linux-aarch64` and `uboot-raspberrypi`.
- Bootloader updates when the `refind` package is updated with pacman hooks.
- Console: Suppresses info messages popping up in console and adjusts font and size for larger displays to Lat2-Terminus16
