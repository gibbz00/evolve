# Configuring `evolve.env`

### Required
- HARDWARE=`uefi`/`rpi4`: Required for specifying the hardware targets and in turn their special setup commands. Match value to alias in supported hardware table of [README.md](README.md).
- CPU_MANUFACTURER=`intel`/`amd`: Used to install and set up the [CPU microcode](https://wiki.archlinux.org/title/Microcode).
- PARTITION_ALGO=`linux-only`/`windows-preinstalled`: Further explained at [PARTITIONING.md](PARTITIONING.md).
- HOST_NAME: Primarily used to `ssh username@hostname`. Consists of lowercase a-z, 0-9, and hyphens. May not being with a hyphen.
- ROOT_PASSWORD: Self explanatory.*
- USER_PASSWORD: Self-explanatory.*
- USERNAME: Self-explanatory.
- TIMEZONE: Possible values: [`timedatectl list-timezones`](https://gist.github.com/gibbz00/b7a96a12b78d5e282bd8fa2cd923513f)

### Optional
- SSH_SERVER=`boolean`: Will install `openssh` and enable the ssh daemon on the target device if set to true. (Happens regardless when `HARDWARE=rpi4`)
- GUI=`boolean`: Sets up graphical user interface if set to true. Details presented in [ARCHITECTURE.md](ARCHITECTURE.md)
- SWAP_CAPS_ESCAPE=`boolean`: Convenient for those using modal editors such as those in the Vim family.
- SWAP_LCTRL_LALT=`boolean`: Save pinky strain by instead using the thumb to reach the control key.n
- GIT_USERNAME: Used to sign commits.
- GIT_EMAIL_ADRESSS: Ditto.
- GITHUB_TOKEN: For GitHub CLI authentication. Minimum required scopes for the provided token are: "repo", "read:org".*
- RUST_TOOLCHAIN=`stable/nightly/<version_number>`: Installs rustup as an [Arch inux package](https://wiki.archlinux.org/title/Rust#Arch_Linux_package) and installs the given toolchain to be used as a default. Additional toolchains can always be installed with `rustup toolchain install <toolchain>`.)
The LSP server for rust (`rust-analyzer`) is optionally added by listing it in `packages`.

Optional env values that are not `boolean` are simply opted out from by not filling them in.

*The installation script makes sure that the entirety evolve directory is removed upon successful install, both on target machine and on installation medium. 
The preparation machine is also removed of all plain-text passwords and auth tokens from `evolve.env`.

### Through `.config`

Locales can be a bit tricky. And I've chosen to go the route in which they're defined in [`skel/tui/.config/locale.conf`](skel/tui/.config/locale.conf). A further explanation as for why that is the case can be found in that file.
