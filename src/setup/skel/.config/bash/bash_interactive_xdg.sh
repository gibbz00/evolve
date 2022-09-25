#!/bin/sh

# Created by the Evolve project.
# This script forces bash to be more compliant to the XDG base directory specification. 
# It is copied into /etc/profile.d/ upon initial system setup.
# (Inspired by: https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/)

_confdir=${XDG_CONFIG_HOME:-$HOME/.config}/bash
_datadir=${XDG_DATA_HOME:-$HOME/.local/share}/bash

# TODO: is this really required?
HISTFILE=$_datadir/history

test -r "$_confdir/bashrc" && . "$_confdir/bashrc"
mkdir --parents "$_datadir"

unset _confdir
unset _datadir
