#!/usr/bin/env bash
# Run the sort pipeline and verify point count + monotonic X ordering.
# Design-only example: run against PDAL 2.10.0 and compare with README.md.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
cp "$DIR/pipeline.json" "$TMP_DIR/pipeline.json"
python3 "$DIR/../01-info/generate.py" "$TMP_DIR/synthetic.txt"
cd "$TMP_DIR"

python3 -m json.tool pipeline.json > /dev/null
pdal pipeline pipeline.json

pdal info --summary sorted.las > sorted-summary.json
python3 - sorted-summary.json <<'PY'
import json
import sys
payload = json.load(open(sys.argv[1], encoding="utf-8"))
summary = payload.get("summary", {})
count = summary.get("num_points", summary.get("count"))
if count != 12:
    raise SystemExit(f"Expected 12 sorted points, got {count}")
print(f"PASS: sorted LAS contains {count} points")
PY

pdal translate sorted.las sorted.txt
python3 - sorted.txt <<'PY'
import sys
from pathlib import Path
values = [float(line.split()[0]) for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines() if line.strip()]
if len(values) != 12:
    raise SystemExit(f"Expected 12 X values, got {len(values)}")
if values != sorted(values):
    raise SystemExit(f"X values are not monotonically ascending: {values}")
print(f"PASS: X values are monotonic ({len(values)} points)")
PY
