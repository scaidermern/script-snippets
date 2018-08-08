#!/bin/sh
#
# print total memory usage in percent of each user logged in
#
# 1st column: user
# 2nd column: memory usage
#
# to sort by memory usage, pipe the output to 'sort -k2 -nr'
#

set -e

total=$(free | awk '/Mem:/ { print $2 }')

for USER in $(who | awk '{print $1}' | sort -u)
do
    ps hux -U $USER | awk -v user=$USER -v total=$total '{ sum += $6} END { printf "%s %.2f\n", user, sum / total * 100; }'
done
