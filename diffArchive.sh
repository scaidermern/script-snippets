#!/bin/sh
#
# shows the diff of two archive contents
#

set -e

if [ "$#" -ne 2 ]; then
    echo "error: need two arguments"
    exit 1
fi

# get full path of files
THIS=$(readlink -f "$1")
THAT=$(readlink -f "$2")

# create temporary directories
THISDIR=$(mktemp -d tmpDiffArchive.XXX)
THATDIR=$(mktemp -d tmpDiffArchive.XXX)
echo "created temporary directories \"$THISDIR\" \"$THATDIR\""

echo "extracting \"$THIS\" to \"$THISDIR\""
(cd "$THISDIR" && tar xf "$THIS")

echo "extracting \"$THAT\" to \"$THATDIR\""
(cd "$THATDIR" && tar xf "$THAT")

# do the diff!
# -c context
# -p show C function
# -r recursive
# -w ignore white spaces
colordiff -u5 -p -r -w "$THISDIR" "$THATDIR" | less -R

rm -rf "$THISDIR" "$THATDIR"
echo "deleted temporary directories \"$THISDIR\" \"$THATDIR\""

