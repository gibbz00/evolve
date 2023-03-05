#!/bin/sh
set -e

. './evolve.env'
. './hidden.env'

# Somewhat less exposed way of non-interactive ssh password login
# See man 1 sshpass
# TODO: Do I have to export it?
export SSHPASS="$_ssh_initial_root_passwd"
sshpass -e ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" root@"$HOST_NAME" "
    cd /root/evolve
    ./setup/main.sh
"
unset SSHPASS

echo "
Finished :) Future ssh logins done by:

$ ssh $USERNAME@$HOST_NAME
"
