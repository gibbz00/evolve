#!/bin/sh

# $1 match $2 path
uncomment_util(){
    sed --expression "s/^#$1/$1/" --in-place "$2"
}

# $1 packages list path
install_packages_util() {
    PACKAGES=$(sed -e '/#/d' "$1" | tr --squeeze-repeats '\n ' ' ')
    su "$USERNAME" --login -c "
        cd /home/$USERNAME 
        . .config/bash/xdg_base.env
        paru -S $PACKAGES --noconfirm --needed
    "
}
