#!/bin/sh
#
# recursively list files sorted by creation date
#

find $* -mount -exec stat --printf="%w\t%n\n" {} + | sort -n
