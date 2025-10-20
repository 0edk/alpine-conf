#!/bin/sh
main_user=`ls -t /home | tail -n 1`
logfile='/tmp/acpi_log'
if [ "$1" = customslock ]
then
    LA="$(grep "$UID" /etc/passwd | cut -d ':' -f 5) | ${USER}@${HOSTNAME}"
    LB="Locked at $(date '+%Y-%jT%H:%M:%S')"
    BD='/sys/class/power_supply/BAT0'
    BN=`cat "$BD/charge_now"`
    BF=`cat "$BD/charge_full"`
    LC="with $((100*BN/BF))% battery"
    DT=`printf '%s\n%s\n%s' "$LA" "$LB" "$LC"`
    /usr/local/bin/slock -m "$DT" &
else
    DISPLAY="${DISPLAY:-:0}"
    export DISPLAY
    BL=`su "$main_user" -c 'ibus read-config' | grep 'preload' | \
        grep -o "'[^']\+'" | head -n 1 | tr -d "'"`
    su "$main_user" -c "ibus engine $BL"
    su "$main_user" "$0" customslock
    sleep 0.2
    if [ -f /tmp/hibernate ]
    then
        rm /tmp/hibernate
        echo disk >/sys/power/state
    else
        echo mem >/sys/power/state
    fi
    sleep 3
    if grep 'eduroam' /etc/wpa_supplicant/wpa_supplicant.conf
    then
        ping -c 1 -W 1 8.8.8.8 >/dev/null || rc-service networking restart
    fi
fi
