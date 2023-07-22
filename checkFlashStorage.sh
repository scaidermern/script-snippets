#!/bin/sh
#
# check health of USB flash drive, SD card or other (flash) storage.
# this is a very simple check. it writes random data to the given target
# directory (e.g.  the mount point of a flash storage) until it is full.
# then it reads from it again and compares the result.
#

set -e

prefix=$(basename "$0" .sh)

if [ "$#" -ne 1 ]; then
    echo "error: please specify target directory (e.g. the mount point of your flash storage)"
    exit 1
fi

dir="$1"
cd "$dir"

# create source file if exists
src="$prefix-first"
if ! [ -f "$src" ]; then
    echo "creating source file $src"
    dd if=/dev/urandom of="$src" bs=1M count=100
fi

# fill target dir by creating duplicates of source file
echo "copying source file until target directory $dir is full"
i=0
while true; do
    suffix=$(printf "%06d" $i)
    dst="$prefix-$suffix"
    if ! [ -f "$dst" ]; then
	echo "creating file $dst"
        if ! cp "$src" "$dst"; then
	    echo "error creating file, $dir is probably full"
	    # remove file because it will have a different content
	    # if it has been created only partially
	    rm -f "$dst"
	    break
	fi
	# show progress
	df -H --output=used,size,pcent "$dir" | awk 'NR==2 {printf "%s/%s (%s)\n", $1,$2,$3}'
    fi
    i=$((i + 1))
done

echo "sync'ing"
sync

# check if all files have the same content by generating a hash of each file
echo "checking file contents"
sums="/tmp/$prefix.sums"
>"$sums"
find "$dir" -type f -name "$prefix*" -print0 | xargs -0 md5sum >> "$sums"

# check if hashes are equal
result="/tmp/$prefix.result"
sort "$sums" | uniq -w 32 > "$result"
echo "result written to $result"
if [ $(wc -l < "$result") -ne "1" ]; then
    echo "check failed. check content of $result. if it contains more than one line then there is likely a problem with your flash storage."
else
    echo "check succeeded. your flash storage is probably fine."
fi
echo "you can remove $dir or its content now."
