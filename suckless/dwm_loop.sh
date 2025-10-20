#!/bin/sh

echo "$PATH"
PATH="${PATH}:${HOME}/bin"
while true
do
    xsetroot -name "$(statusbar_text)"
    sleep 2
done
