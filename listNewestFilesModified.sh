#!/bin/sh
#
# recursively list files sorted by data modification date
#

find . -mount -exec stat --printf="%y\t%n\n" {} + | sort -n
