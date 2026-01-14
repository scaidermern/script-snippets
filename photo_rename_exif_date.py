#!/usr/bin/env python3
""" Rename photos based on their EXIF time stamps """

import argparse
import datetime
import os
import sys

from pathlib import Path
from PIL import Image, ExifTags

def get_exif_date(file):
    """Return photo time stamp from EXIF data"""

    img = Image.open(file)
    exif = img.getexif()
    if exif is None:
        return None

    exif_dt = exif.get(ExifTags.Base.DateTime)
    if exif_dt is None:
        return None

    date = datetime.datetime.strptime(exif_dt, '%Y:%m:%d %H:%M:%S')
    return date

def get_new_file_name(file, date, prefix, suffix, omit_orig_name, delimiter):
    """ Construct new file name """

    return (
        f'{prefix or ""}'
        f'{delimiter or "" if prefix else ""}'
        f'{date.timestamp()}'
        f'{delimiter or "" if not omit_orig_name else ""}'
        f'{Path(file).stem if not omit_orig_name else ""}'
        f'{delimiter or "" if suffix else ""}'
        f'{suffix or ""}'
        f'{Path(file).suffix}')

def rename_file(file, new_name, dry_run):
    """ Rename file from file to new_name"""

    if dry_run:
        print(f'{file} -> {new_name}')
    else:
        os.rename(file, new_name)

def main() -> int:
    """main"""

    parser = argparse.ArgumentParser(
        prog='photo_rename_exif_date',
        description='Rename photos based on their EXIF time stamps',
        epilog=(
            'example:\n'
            f'  {sys.argv[0]} -p myprefix -s mysuffix -n *.jpg\n'
            '  picture_9.jpg  -> myprefix_1767177800.0_picture_9_mysuffix.jpg\n'
            '  picture_10.jpg -> myprefix_1767177801.0_picture_10_mysuffix.jpg'),
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('files', nargs='*', help='image files to read')
    parser.add_argument('-p', '--prefix',
        help='prefix of the new image file name (before the time stamp)')
    parser.add_argument('-s', '--suffix',
        help='suffix of the new image file name (after the time stamp)')
    parser.add_argument('-o', '--omit', action='store_true', default=False,
        help='omit inserting the original file name')
    parser.add_argument('-d', '--delimiter', default='_',
        help='delimiter between prefix/suffix and time stamp of the new image file name '
            '(default: "_")')
    parser.add_argument('-n', '--dry-run', action='store_true', default=False,
        help='don\'t rename the files, just print what would happen')

    args = parser.parse_args()

    for file in args.files:
        date = get_exif_date(file)
        if date is None:
            continue
        new_file_name = get_new_file_name(
            file, date, args.prefix, args.suffix,
            args.omit, args.delimiter)
        rename_file(file, new_file_name, args.dry_run)

if __name__ == '__main__':
    sys.exit(main())
