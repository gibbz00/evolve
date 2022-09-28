#!/bin/sh
set -xe

. ../evolve.env

# Somewhat less exposed way of non-interactive ssh password login
# See man 1 sshpass
SSHPASS="root"
export SSHPASS="root"
sshpass -e ssh -o StrictHostKeyChecking=no root@$HOST_NAME "
    cd /root/evolve/setup
    ./setup.sh
"
# Remain logged in
SSHPASS="$USER_PASSWORD"
sshpass -e ssh -o StrictHostKeyChecking=no $USERNAME@$HOST_NAME
unset SSHPASS
