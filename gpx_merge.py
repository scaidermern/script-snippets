#!/usr/bin/env python3
"""Merges multiple GPX files into a single file"""

import argparse
import sys
from dataclasses import dataclass

@dataclass
class GpxMerge:
    """Merger for multiple GPX files

    Attributes:
        title (str): Title of the GPX file
        combine (bool): Whether to combine everything into a single <trk> and <trkseg> element
            (skip any <trk> and <trkseg> elements inbetween)
    """
    title: str
    combine: bool = False

    def add_header(self, out):
        """Add GPX header"""

        out.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        out.write('<gpx\n')
        out.write(' xmlns="http://www.topografix.com/GPX/1/1"\n')
        out.write(' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n')
        out.write(' xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
            'http://www.topografix.com/GPX/1/1/gpx.xsd"\n')
        out.write(' version="1.1">\n')

        if self.title:
            out.write(f' <title>{self.title}</title>\n')

        if self.combine:
            # write our own <trk> and <trkseg> sections,
            # skip any further <trk> and <trkseg> while dumping
            out.write(' <trk>\n')
            out.write('  <trkseg>\n')

    def add_footer(self, out):
        """Add GPX trailer"""
        if self.combine:
            # <trk> and <trkseg> sections
            out.write('  </trkseg>\n')
            out.write(' </trk>\n')

        out.write('</gpx>\n')

    def parse_file(self, out, file):
        """Parse given GPX file and write data to given output file"""

        print(f'Merging {file}')
        do_dump = False
        with open(file, encoding='utf-8') as infile:
            for line in infile:
                skip_line = False

                if '<trk>' in line:
                    # start dumping into output file
                    do_dump = True

                if '</gpx>' in line:
                    # stop dumping into output file
                    return

                if self.combine:
                    # skip dumping any <trk> and <trkseg> section,
                    # also skip names so that they don't appear inbetween
                    if any(word in line for word in
                        ('<trk>', '</trk>', '<trkseg>', '</trkseg>', '<name>')):
                        skip_line = True

                if do_dump and not skip_line:
                    out.write(line)

    def run(self, outfile, files):
        """Perform all the magic"""

        with open(outfile, 'w', encoding='utf-8') as out:
            self.add_header(out)
            for file in files:
                self.parse_file(out, file)
            self.add_footer(out)

def main() -> int:
    """main"""

    parser = argparse.ArgumentParser(
        prog='GPX merger',
        description='merges multiple GPX files into a single file')
    parser.add_argument('files', nargs='*', help='GPX files to merge')
    parser.add_argument('-o', '--outfile', required=True, help='output file')
    parser.add_argument('-t', '--title', help='title of the GPX file')
    parser.add_argument('-c', '--combine', action='store_true', help=
        'enclose everything into a single <trk> and <trkseg> element '
        '(skip any <trk> and <trkseg> elements inbetween)')

    args = parser.parse_args()

    merger = GpxMerge(args.title, args.combine)
    merger.run(args.outfile, args.files)

    return 0

if __name__ == '__main__':
    sys.exit(main())
