#!/bin/sh

show_bar() {
    badness="$1"
    if [ -n "$2" ]
    then
        printf '^c#%s^' "$2"
    fi
    length=`printf '20*%f\n' "$badness" | bc -l`
    length="${length%.*}"
    length="${length:-0}"
    printf '^r0,3,%d,14^^f%d^' "$length" "$((length+2))"
}

batt_dir='/sys/class/power_supply/BAT0'
printf '^d^^r5,1,4,3^^r3,3,8,15^'
batt_state="$(cat "${batt_dir}/status")"
case "$batt_state" in
    Charging) printf '^c#FFFF00^^r5,6,4,9^' ;;
    Full) printf '^c#00FF00^^r5,6,4,9^' ;;
    Discharging) ;;
    Unknown) ;;
esac
printf '^f15^'
batt_now="$(cat "${batt_dir}/charge_now")"
batt_full="$(cat "${batt_dir}/charge_full")"
batt_severe=`printf 'l(%d/%d)/l(2)\n' "$batt_full" "$batt_now" | bc -l`
show_bar "$batt_severe" "FFFF00"

printf '^d^^r4,4,12,12^^r5,1,2,18^^r9,1,2,18^^r13,1,2,18^'
printf '^r1,5,18,2^^r1,9,18,2^^r1,13,18,2^^f24^'
load_line=`cat /proc/loadavg`
load_cur="${load_line%% *}"
show_bar `printf '-l(1-%f/4)/l(2)\n' "$load_cur" | bc -l` "FF8000"

printf '^d^^r5,1,2,1^^r4,2,4,12^^r3,11,6,8^^r2,12,8,6^^f13^'
therm_line=`sensors -u | grep 'temp4_input' | head -n 1 | sed 's/ \+/\t/g'`
therm_num=`echo "$therm_line" | cut -f 3 | cut -d '.' -f 1`
show_bar `printf '-l(1-%d/80)/l(2)\n' "$therm_num" | bc -l` "FF00FF"

printf '^d^^r6,1,2,7^^r1,8,12,2^^r1,11,12,2^^r6,13,2,7^^f17^'
mem_line=`free | grep '^Mem:' | sed 's/ \+/\t/g'`
mem_total=`echo "$mem_line" | cut -f 2`
mem_avail=`echo "$mem_line" | cut -f 7`
show_bar `printf 'l(%d/%d)/l(2)\n' "$mem_total" "$mem_avail" | bc -l` "00FFFF"

printf '^d^'
date '+%jT%H:%M'
exit 0

date '+%y-%jT%H:%M'
