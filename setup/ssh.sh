#!/bin/sh
. ./context.sh

# Somewhat less exposed way of non-interactive ssh password login
# See man 1 sshpass
export SSHPASS="$_ssh_initial_root_passwd"
sshpass -e ssh -o StrictHostKeyChecking=no root@"$HOST_NAME" "
    cd /root/evolve
    ./setup/main.sh
"
unset SSHPASS

echo "
Finished :) Future ssh logins done by:

$ ssh $USERNAME@$HOST_NAME
"
