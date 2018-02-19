#!/bin/sh
#
# print total CPU usage in percent of all available users
# but skips the ones with a CPU usage of zero
#
# to sort by CPU usage, pipe the output to 'sort -k2 -nr'
#

set -e

OWN=$(id -nu)

for USER in $(getent passwd | awk -F ":" '{print $1}' | sort -u)
do
    # print other user's CPU usage in parallel but skip own one because
    # spawning many processes will increase our CPU usage significantly
    if [ "$USER" = "$OWN" ]; then continue; fi
    (top -b -n 1 -u "$USER" | awk -v user=$USER 'NR>7 { sum += $9; } END { if (sum > 0.0) print user, sum; }') &
    # don't spawn too many processes in parallel
    sleep 0.05
done
wait

# print own CPU usage after all spawned processes completed
top -b -n 1 -u "$OWN" | awk -v user=$OWN 'NR>7 { sum += $9; } END { print user, sum; }'
