#!/usr/bin/env bash
# Round-trip one small cloud: LAS -> LAZ -> text, asserting point counts.
# Design-only example: run against PDAL 2.10.0 and validate runtime behavior.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$DIR/../01-info/synthetic.las"
LAZ="$DIR/synthetic.laz"
ROUNDTRIP="$DIR/roundtrip.txt"
LAS_SUMMARY="$DIR/las-summary.json"
LAZ_SUMMARY="$DIR/laz-summary.json"

if [[ ! -s "$SOURCE" ]]; then
  echo "Missing $SOURCE. Run examples/01-info/generate.py and info.sh first." >&2
  exit 2
fi

pdal translate "$SOURCE" "$LAZ"
pdal translate "$LAZ" "$ROUNDTRIP"
pdal info --summary "$SOURCE" > "$LAS_SUMMARY"
pdal info --summary "$LAZ" > "$LAZ_SUMMARY"

python3 - "$LAS_SUMMARY" "$LAZ_SUMMARY" "$ROUNDTRIP" <<'PY'
import json
import sys
from pathlib import Path

def point_count(path: str) -> int:
    with open(path, encoding="utf-8") as stream:
        payload = json.load(stream)
    summary = payload.get("summary", {})
    value = summary.get("num_points", summary.get("count"))
    if not isinstance(value, int):
        raise SystemExit(f"{path}: PDAL summary has no integer point count")
    return value

las_count = point_count(sys.argv[1])
laz_count = point_count(sys.argv[2])
text_rows = sum(1 for line in Path(sys.argv[3]).read_text(encoding="utf-8").splitlines() if line.strip())
if las_count != 12:
    raise SystemExit(f"Expected 12 points in source LAS, got {las_count}")
if laz_count != las_count:
    raise SystemExit(f"LAS/LAZ point count mismatch: {las_count} != {laz_count}")
if text_rows != las_count:
    raise SystemExit(f"LAZ/text row mismatch: {laz_count} != {text_rows}")
print(f"PASS: LAS={las_count}, LAZ={laz_count}, text rows={text_rows}")
PY
