#!/bin/sh

# Created by the Evolve project.
# This script forces bash to be more compliant to the XDG base directory specification. 
# It is copied into /etc/profile.d/ upon initial system setup.
# (Inspired by: https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/)

_confdir=${XDG_CONFIG_HOME:-$HOME/.config}/bash
_datadir=${XDG_DATA_HOME:-$HOME/.local/share}/bash

# TODO: is this really required? is also being set in bash_interactive_xdg.sh
HISTFILE="$_datadir/history"

if test -d "$_confdir"
then
    for file in bash_profile bashrc; do
        # TODO: do I really need to test for the existence of the respective files?
        #   Can't see why. If it doesn't exist, well; then it doesn't exist. 
        #       Might just redicrect errors to /dev/null intead
        #   Changes would imply the removal of the outer if statement
        test -f "$_confdir/$file" && . "$_confdir/$file" # 2>/dev/null
    done
fi

# Change the location of the history file by setting the environment variable
mkdir --parents "$_datadir"

unset _confdir
unset _datadir
