#!/bin/bash
# TEMP: 
neofetch

# Choose console keyboard layout
# Relies on systemd, its why its here rather than in setup.
# https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration 
# TODO: make make dynamic based on config
# TODO: localectl tries to change xorg layout too, is there a way to do the same with wl_roots? 
# TODO: doing the escape:caps and ctl:alt change should be make here as well, not only in gui mode
#localectl set-keymap sv-latin1

