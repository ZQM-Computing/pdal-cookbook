#!/usr/bin/env bash
# Run the sort pipeline and assert 12 points with monotonically increasing X.
# Design-only example: runtime behavior still requires PDAL 2.10.0.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$DIR/../01-info/generate.py"
python3 -m json.tool "$DIR/pipeline.json" > /dev/null
(
  cd "$DIR"
  pdal pipeline pipeline.json
)
SUMMARY="$DIR/sorted-summary.json"
SORTED_TEXT="$DIR/sorted.txt"
pdal info --summary "$DIR/sorted.las" > "$SUMMARY"
pdal translate "$DIR/sorted.las" "$SORTED_TEXT"
python3 - "$SUMMARY" "$SORTED_TEXT" <<'PY'
import json
import sys
from pathlib import Path

payload = json.load(open(sys.argv[1], encoding="utf-8"))
summary = payload.get("summary", {})
count = summary.get("num_points", summary.get("count"))
if count != 12:
    raise SystemExit(f"Expected 12 sorted points, got {count!r}")
rows = []
for line in Path(sys.argv[2]).read_text(encoding="utf-8").splitlines():
    if line.strip():
        rows.append(float(line.split()[0]))
if len(rows) != 12:
    raise SystemExit(f"Expected 12 translated rows, got {len(rows)}")
if rows != sorted(rows):
    raise SystemExit(f"X values are not monotonically increasing: {rows}")
print(f"PASS: {count} points; X values sorted ascending ({rows[0]}..{rows[-1]}).")
PY
