#!/usr/bin/env python3
"""Collect PNG slides and package into a ZIP for Figma import."""
import sys
import os
import zipfile


def make_zip(png_dir, out_zip):
    if not os.path.isdir(png_dir):
        raise SystemExit(f'PNG directory not found: {png_dir}')
    with zipfile.ZipFile(out_zip, 'w', zipfile.ZIP_DEFLATED) as z:
        for fname in sorted(os.listdir(png_dir)):
            if fname.lower().endswith('.png'):
                z.write(os.path.join(png_dir, fname), arcname=fname)
    print('Created', out_zip)


def main():
    if len(sys.argv) < 3:
        print('Usage: python tools/make_figma_zip.py path/to/png_dir out.zip')
        sys.exit(1)
    make_zip(sys.argv[1], sys.argv[2])


if __name__ == '__main__':
    main()
