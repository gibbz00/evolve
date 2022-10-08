#!/bin/sh

pid=$(pgrep -u $USER --full "inactive-windows-transparency.py")
if test $pid 
then
	kill $pid
else
	exec /usr/share/sway/scripts/inactive-windows-transparency.py  --active-opacity 0.95 --inactive-opacity 0.85
fi
