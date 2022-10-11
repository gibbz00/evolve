#!/bin/sh
set -e

. "./evolve.env"

# Somewhat less exposed way of non-interactive ssh password login
# See man 1 sshpass
export SSHPASS="root"
sshpass -e ssh -o StrictHostKeyChecking=no root@"$HOST_NAME" "
    cd /root/evolve
    ./setup/main.sh
"

echo "
Finished :) Future ssh logins done by:

$ ssh $USERNAME@$HOST_NAME
"
