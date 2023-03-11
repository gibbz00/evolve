#!/bin/sh
ANS="$(echo "Lock|Logout|Reboot|Shutdown" | rofi -dmenu -sep "|" -p 'System Exit' -hide-scrollbar )"

case "$ANS" in
	*Lock) swaylock --image '$WALLPAPER' ;;
	*Logout*) swaymsg exit ;;
	*Reboot) systemctl reboot ;;
	*Shutdown) systemctl -i poweroff ;;
esac
