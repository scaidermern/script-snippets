#!/bin/sh
#
# creates user and system backup.
# pass option -f to create a full system backup instead of a compact one.
#

basedir=$(dirname "$0")

# exclude files and directories listed in these files,
# user-specific excludes:
excl_home="$basedir/backup_excludes_home.txt"
# system-specific excludes:
excl_sys="$basedir/backup_excludes_sys.txt"

# check for exclude files
if ! [ -f "$excl_home" ]; then
    echo "exclude file \"$excl_home\" is missing!"
    exit 1
fi
if ! [ -f "$excl_sys" ]; then
    echo "exclude file \"$excl_sys\" is missing!"
    exit 1
fi

# check for root
if ! [ $(id -u) = 0 ]; then
    echo "warning: you should be root to run this script."
    echo
    sleep 5
fi

# check options
if [ "$1" = "-f" ]; then
    full_backup="1"
fi

# tar options and extension
#  -c create
#  -p preserve permissions
#  -j bzip2 compression
#  -J xz compression
#  -z gzip compression
#  -v verbose output
#  -f filename
tar_opts="cpJvf"
tar_ext="tar.xz"

# enable parallel compression for xz
export XZ_DEFAULTS="-T 0"

# create backup
date="$(date +%Y-%m-%d)"
file_base="backup-$(hostname)-$date"
file_home="${file_base}-home.$tar_ext"
echo "creating user backup $file_home"
time tar $tar_opts "$file_home" --exclude-from="$excl_home" /home/ /root/ 2>"${file_base}-home.log"
echo
if ! [ $full_backup ]; then
    file_sys="${file_base}-sys.$tar_ext"
    echo "creating system backup $file_sys"
    time tar $tar_opts "$file_sys" --exclude-from="$excl_sys" /etc/ /var/spool/ /var/www/ 2>"${file_base}-sys.log"
else
    file_sys="${file_base}-sys-full.$tar_ext"
    echo "creating full system backup $file_sys"
    time tar $tar_opts "$file_sys" --exclude-from="$excl_sys" / 2>"${file_base}-sys.log"
fi

echo
echo "done."
