#!/usr/bin/env bash

## set the key repeat rate
#xset r rate 200 100

# unify clipboards
# autocutsel -s CLIPBOARD &
# autocutsel -s PRIMARY &

# disable touchpad
xinput --list | \
grep TouchPad | \
awk '{print$6}' | \
grep -o '[0-9]\+' | \
xargs xinput --disable

# hack to start the ModemManager service
# see https://github.com/NixOS/nixpkgs/issues/11197
# alternatively, one has to run `systemctl start ModemManager.service`
# dbus-send --system --dest=org.freedesktop.ModemManager1 --print-reply /org/freedesktop/ModemManager1 org.freedesktop.DBus.Introspectable.Introspect

# turn off power led
light -S 0 -s sysfs/leds/tpacpi::power

# set background
feh --bg-tile black-pixel.png
