#!/bin/bash
# 
# kbdbrightness.sh
#
# $1 = up/down

echo 'logging $1' > /home/randy/log.txt
[[ "$1" = "up" ]] && echo 3 > /sys/class/leds/asus\:\:kbd_backlight/bright
[[ "$1" = "down" ]] && echo 0 > /sys/class/leds/asus\:\:kbd_backlight/bright

