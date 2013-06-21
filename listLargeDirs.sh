#!/bin/sh
#
# recursively list directories sorted by content size
#

find . -mount -type d -exec du -s "{}" \; | sort -n
