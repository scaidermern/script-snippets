#!/bin/sh
#
# list installed debian packages sorted by size
#

dpkg-query -W -f '${Status}\t${Installed-Size}\t${Package}\n' | grep "^install ok" | cut -f2-3 | sort -n
