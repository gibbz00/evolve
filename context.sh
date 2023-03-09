#!/bin/bash

set -e 

. ./evolve.env
. ./utils.sh

# Used internally by the evolve scrips and not meant to be configured!
# Otherwise the install process might very well break.
_ssh_initial_root_passwd='root'

# https://uapi-group.org/specifications/specs/discoverable_partitions_specification/
# used to specify the root partition in /boot/refind_linux.conf
_sd_gpt_root_part_uuid="44479540-f297-41b2-9af7-d131d5f0458a"