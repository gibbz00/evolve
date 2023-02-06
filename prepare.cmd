# Based on https://learn.microsoft.com/en-us/windows/wsl/install-manual
set -e
. evolve.env

# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# Enable Vistual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --install
wsl --set-default-version 2

# Install Scoop package manager
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Use scoop to install ArchWSL
scoop install git
scoop bucket add extras
scoop install archwsl

# Make sure the WSL instance is opened in the current directory, but as root
arch.exe run setup.sh

arch.exe config --default-user "$USERNAME"
