#!/usr/bin/env bash
# Run local file stages in an isolated temporary directory.
# Database ingestion is optional and requires an operator-configured pipeline
# outside this repository's placeholder connection configuration.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
cp "$DIR/../03-pipeline-json/pipeline.json" "$TMP_DIR/pipeline.json"
cd "$TMP_DIR"

echo "=== stage 1: generate synthetic data ==="
python3 "$DIR/../01-info/generate.py"
test -s synthetic.txt

echo "=== stage 2: inspect source points ==="
pdal translate synthetic.txt synthetic.las \
  --readers.text.header "X,Y,Z,Intensity" \
  --readers.text.separator " "
pdal info --summary synthetic.las > source-summary.json
python3 - source-summary.json <<'PY'
import json, sys
payload = json.load(open(sys.argv[1], encoding="utf-8"))
summary = payload.get("summary", {})
count = summary.get("num_points", summary.get("count"))
if count != 12:
    raise SystemExit(f"Expected 12 source points, got {count}")
print(f"PASS: source cloud has {count} points")
PY

echo "=== stage 3: sort through the PDAL JSON pipeline ==="
python3 -m json.tool pipeline.json > /dev/null
pdal pipeline pipeline.json
pdal info --summary sorted.las > sorted-summary.json
python3 - sorted-summary.json sorted.las <<'PY'
import json, sys
from pathlib import Path
payload = json.load(open(sys.argv[1], encoding="utf-8"))
summary = payload.get("summary", {})
count = summary.get("num_points", summary.get("count"))
if count != 12:
    raise SystemExit(f"Expected 12 sorted points, got {count}")
print(f"PASS: sorted cloud has {count} points")
PY
pdal translate sorted.las sorted.txt
python3 - sorted.txt <<'PY'
import sys
from pathlib import Path
values = [float(line.split()[0]) for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines() if line.strip()]
if len(values) != 12 or values != sorted(values):
    raise SystemExit(f"Expected 12 X-sorted points; got {values}")
print("PASS: all 12 points sorted by X")
PY

if [[ -n "${PDAL_PGPOINTCLOUD_PIPELINE:-}" ]]; then
  if [[ ! -s "$PDAL_PGPOINTCLOUD_PIPELINE" ]]; then
    echo "PDAL_PGPOINTCLOUD_PIPELINE is set but not a readable file." >&2
    exit 2
  fi
  echo "=== stage 4: operator-supplied pgPointCloud pipeline ==="
  pdal pipeline "$PDAL_PGPOINTCLOUD_PIPELINE"
else
  echo "SKIP: database stage not run; set PDAL_PGPOINTCLOUD_PIPELINE to a separately configured pipeline."
fi
