#!/bin/bash
export WALLPAPER="$HOME/media/wallpapers/fish.jpg"

_screenshot_dir="/tmp/screenshots"
mkdir --parents "$_screenshot_dir"
export SWAY_ROFI_SCREENSHOT_SAVEDIR="$_screenshot_dir"
# used in sway config
export XDG_CONFIG_HOME="$HOME/.config"

## Sway TTY startup inserted from evolve/setup/gui.sh 
