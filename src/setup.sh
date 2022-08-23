# Following the recommendations from:
# https://hub.docker.com/_/archlinux/
# TEMP: commented out to reduce build times
# set -xe; \
#    pacman-key --init; \
#    pacman -Syyu --noconfirm;
pacman -Sy

# Select mirror servers by download rate
# pacman-contrib includes rankmirrors script
pacman -S pacman-contrib --noconfirm --needed;
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -s "https://archlinux.org/mirrorlist/?country=SE&protocol=https&use_mirror_status=on" \
| sed -e 's/^#Server/Server/' -e '/^#/d' \
| rankmirrors -v -n 5 - \
> /etc/pacman.d/mirrorlist

# Install packages
PACKAGES=$(sed -e '/^#/d' "$BUILD_DIRECTORY/packages" | tr '\n' ' ')
pacman -S $PACKAGES --noconfirm --needed

# Add root password and user credentials
# useradd -m -G users,wheel username
# echo "username:password" | chpasswd
# passwd
