#!/bin/sh

# Created by the Evolve project.
# https://github.com/gibbz00/evolve

# This script forces bash to be more compliant to the XDG base directory specification. 
# It is copied into /etc/profile.d/ upon initial system setup.
# (Inspired by: https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/)

config_directory=${XDG_CONFIG_HOME:-$HOME/.config}/bash
test -r "$config_directory/bashrc" && . "$config_directory/bashrc"
unset config_directory
