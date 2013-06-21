#!/bin/sh
#
# small 'daemon' to display currently playing mpd song as OSD
# requires aosd_cat from the aosd-cat package (libaosd)
#

# aosd_cat configuration
FADE=1500   # fade in/out (in ms)
#FADE=0
DUR=9000    # duration (between fades, in ms)
COLR="orange" # color
#FONT="Comic Sans MS Bold 100" # font description and size
#FONT="eufm10 Bold 100"
#FONT="Mathematica6 Bold 100"
#FONT="Purisa Bold 100"
FONT="UnPilgi Bold 100"
#FONT="URW Chancery L Bold 100"
SHOFF=5     # shadow offset
POS=4       # position (4=center)

MPC_CALL="mpc -f '[[[%artist% - ]%title%[ (%album%[, %date%])]]|[%file%]]' current"
AOSD_CALL="aosd_cat -f $FADE -o $FADE -u $DUR -R '$COLR' -n '$FONT' -e $SHOFF -p $POS"

SLEEP="0.5s"
LAST_OSD=""

trap cleanup 1 2 3 6
cleanup()
{
    pkill aosd_cat
    exit
}

while true
do
    CUR_OSD=$(eval $MPC_CALL)
    
    if [ "$CUR_OSD" != "$LAST_OSD" ]
    then
    	pkill aosd_cat # previus might be still running due to consecutive song skips
        echo $CUR_OSD | eval $AOSD_CALL &
        LAST_OSD=$CUR_OSD
    fi
    
    sleep $SLEEP
done
