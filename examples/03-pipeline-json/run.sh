#!/usr/bin/env bash
# Run the sort pipeline and verify point count + X ordering.
# Design-only example: run against PDAL 2.10.0 and compare with the
# expected output in README.md.
set -euo pipefail

python3 -m json.tool pipeline.json > /dev/null
pdal pipeline pipeline.json

echo "--- sorted.las count ---"
pdal info --summary sorted.las | grep -i -m1 "count"

echo "--- first column (X) of round-tripped output ---"
pdal translate sorted.las sorted.txt
awk '{print $1}' sorted.txt | tr '\n' ' '
echo
