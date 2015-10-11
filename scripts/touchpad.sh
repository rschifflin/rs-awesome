#!/bin/bash
#
# touchpad.sh
# 
# $1 = on/off

[[ "$1" = "on" ]]  && synclient TouchpadOff=0
[[ "$1" = "off" ]] && synclient TouchpadOff=1
