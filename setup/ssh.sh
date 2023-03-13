#!/bin/bash
. ./context.sh

# Somewhat less exposed way of non-interactive ssh password login
# See man 1 sshpass
export SSHPASS="$_ssh_initial_root_passwd"
sshpass -e ssh -o StrictHostKeyChecking=no root@"$HOST_NAME" "
    cd /root/evolve
    ./setup/main.sh
"
unset SSHPASS

_remove-value() {
    perl -i -pe "s/(?<=^$1=)'.*'/''/" evolve.env
}

_remove-value ROOT_PASSWORD
_remove-value USER_PASSWORD
_remove-value GITHUB_TOKEN

$SSH_SERVER || test "$HARDWARE" = "rpi4" && echo "
Finished :) Future ssh logins done by:

$ ssh $USERNAME@$HOST_NAME
"
