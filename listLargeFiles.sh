#!/bin/sh
#
# recursively list files sorted by size
#

find . -mount -printf "%k\t%p\n" | sort -n
