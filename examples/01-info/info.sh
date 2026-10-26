#!/usr/bin/env bash
# Translate the synthetic text cloud to LAS, then inspect it.
# Design-only example: run against PDAL 2.10.0 and compare with README.md.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

if [[ ! -s synthetic.txt ]]; then
  python3 generate.py
fi

pdal translate synthetic.txt synthetic.las \
  --readers.text.header "X,Y,Z,Intensity" \
  --readers.text.separator " "

echo "--- summary ---"
pdal info --summary synthetic.las

echo "--- metadata (first 60 lines) ---"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
pdal info --metadata synthetic.las > "$TMP_DIR/metadata.json"
head -n 60 "$TMP_DIR/metadata.json"
