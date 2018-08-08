#!/bin/sh
#
# print total CPU usage in percent of currently logged in users.
#
# 1st column: user
# 2nd column: aggregated CPU usage
# 3rd column: normalized CPU usage according to the number of cores
#
# to sort by CPU usage, pipe the output to 'sort -k2 -nr'
#

set -e

own=$(id -nu)
cpus=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

for user in $(who | awk '{print $1}' | sort -u)
do
    # print other user's CPU usage in parallel but skip own one because
    # spawning many processes will increase our CPU usage significantly
    if [ "$user" = "$own" ]; then continue; fi
    (top -b -n 1 -u "$user" | awk -v user=$user -v CPUS=$cpus 'NR>7 { sum += $9; } END { print user, sum, sum/CPUS; }') &
    # don't spawn too many processes in parallel
    sleep 0.05
done
wait

# print own CPU usage after all spawned processes completed
top -b -n 1 -u "$own" | awk -v user=$own -v CPUS=$cpus 'NR>7 { sum += $9; } END { print user, sum, sum/CPUS; }'
