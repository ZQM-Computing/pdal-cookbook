#!/usr/bin/env bash
# Round-trip one small cloud: LAS -> LAZ -> text, with count checks.
# Design-only example: run against PDAL 2.10.0 and compare with the
# expected output in README.md.
set -euo pipefail

pdal translate synthetic.las synthetic.laz
pdal translate synthetic.laz roundtrip.txt

echo "--- original LAS count ---"
pdal info --summary synthetic.las | grep -i -m1 "count"
echo "--- LAZ count ---"
pdal info --summary synthetic.laz | grep -i -m1 "count"
echo "--- round-trip text rows ---"
grep -c -v '^$' roundtrip.txt
