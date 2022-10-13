#!/bin/sh

# Created by the Evolve project and was copied into /etc/bashrc.d/ by system setup scripts.
# https://github.com/gibbz00/evolve

# Forces bash to be more compliant to the XDG base directory specification. 
# (Inspired by: https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/)
config_directory=${XDG_CONFIG_HOME:-$HOME/.config}/bash
test -r "$config_directory/bashrc" && . "$config_directory/bashrc"
unset config_directory
