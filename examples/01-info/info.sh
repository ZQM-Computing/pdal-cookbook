#!/usr/bin/env bash
# Generate the synthetic text cloud, translate it to LAS, then inspect it.
# Design-only example: run against PDAL 2.10.0; CI validates the contract,
# not a live PDAL runtime.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$DIR/generate.py"
pdal translate "$DIR/synthetic.txt" "$DIR/synthetic.las" \
  --readers.text.header "X,Y,Z,Intensity" \
  --readers.text.separator " "

SUMMARY="$DIR/summary.json"
METADATA="$DIR/metadata.json"
pdal info --summary "$DIR/synthetic.las" > "$SUMMARY"
pdal info --metadata "$DIR/synthetic.las" > "$METADATA"

python3 - "$SUMMARY" <<'PY'
import json
import sys
payload = json.load(open(sys.argv[1], encoding="utf-8"))
summary = payload.get("summary", {})
count = summary.get("num_points", summary.get("count"))
if count != 12:
    raise SystemExit(f"Expected 12 points, got {count!r}")
print(f"PASS: generated LAS contains {count} points")
PY
echo "--- metadata (saved to $METADATA) ---"
