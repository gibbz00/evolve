#!/bin/sh
ANS="$(echo " Lock|■ Quit Sway| Reboot| Shutdown" | rofi -dmenu -sep "|" -p 'System Exit' -hide-scrollbar )"

case "$ANS" in
	*Lock) swaylock --image '$WALLPAPER' ;;
	*Quit*) swaymsg exit ;;
	*Reboot) systemctl reboot ;;
	*Shutdown) systemctl -i poweroff ;;
esac
