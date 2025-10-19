#!/bin/sh
PATH="${PATH}:${HOME}/bin"
sleep 0
mpv 2022/alpine_conf/short.ogv &
sleep 0.1
run_dgn
sleep 0.1
anki &
sleep 0.1
cd shortterm
AIU='doas apk -i upgrade#Alpine update'
for TASK in "$AIU" "$MAILA" "$MAILB"
do
    CMD="${TASK%%#*}"
    DESC="${TASK##*#}"
    XS="${XS}; printf '\033]2;routine: ${DESC}\007'; ${CMD}"
done
for profile in ~/.config/mutt/profiles/*
do
    XS="${XS}; printf '\033]2;email: $(basename profile)\007'; mutt -F $profile"
XS="${XS##; }"
xterm -T 'routine' -e "$XS" &
cd ~/perennial/shell_scripting/
