#!/bin/sh

# Created by the Evolve project.
# https://github.com/gibbz00/evolve

# This script forces bash to be more compliant to the XDG base directory specification. 
# It is copied into /etc/profile.d/ upon initial system setup.
# (Inspired by: https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/)

config_directory=${XDG_CONFIG_HOME:-$HOME/.config}/bash

for file in bash_profile bashrc; do
    test -f "$config_directory/$file" && . "$config_directory/$file"
done

unset config_directory
