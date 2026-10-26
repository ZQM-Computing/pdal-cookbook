#!/usr/bin/env bash
# Translate the synthetic text cloud to LAS, then inspect it.
# Design-only example: run against PDAL 2.10.0 and compare with the
# expected output in README.md.
set -euo pipefail

pdal translate synthetic.txt synthetic.las \
  --readers.text.header "X,Y,Z,Intensity" \
  --readers.text.separator " "

echo "--- summary ---"
pdal info --summary synthetic.las

echo "--- metadata (SRS section) ---"
pdal info --metadata synthetic.las | head -60
