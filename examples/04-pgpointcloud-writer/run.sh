#!/usr/bin/env bash
# Render the placeholder writer pipeline with explicit environment credentials.
# This script never writes database credentials into the repository.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${PGHOST:?set PGHOST}"
: "${PGDATABASE:?set PGDATABASE}"
: "${PGUSER:?set PGUSER}"
: "${PGPASSWORD:?set PGPASSWORD}"
: "${PGSCHEMA:?set PGSCHEMA}"
: "${PGTABLE:?set PGTABLE}"
: "${PGPOINTCLOUD_COLUMN:=pa}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
export PDAL_TEMPLATE="$DIR/pipeline.json"
export PDAL_OUTPUT="$TMP_DIR/pipeline.configured.json"
python3 <<'PY'
import json
import os
from pathlib import Path

template = json.loads(Path(os.environ["PDAL_TEMPLATE"]).read_text(encoding="utf-8"))
stages = template.get("pipeline", [])
writers = [stage for stage in stages if stage.get("type") == "writers.pgpointcloud"]
if len(writers) != 1:
    raise SystemExit("Expected exactly one writers.pgpointcloud stage")
writer = writers[0]
writer["connection"] = " ".join((
    f"host={os.environ['PGHOST']}",
    f"dbname={os.environ['PGDATABASE']}",
    f"user={os.environ['PGUSER']}",
    f"password={os.environ['PGPASSWORD']}",
))
writer["schema"] = os.environ["PGSCHEMA"]
writer["table"] = os.environ["PGTABLE"]
writer["column"] = os.environ["PGPOINTCLOUD_COLUMN"]
Path(os.environ["PDAL_OUTPUT"]).write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
PY

cd "$DIR"
if [[ ! -s synthetic.txt ]]; then
  python3 ../01-info/generate.py
  # generate.py writes into this working directory.
fi
python3 -m json.tool "$TMP_DIR/pipeline.configured.json" > /dev/null
pdal pipeline "$TMP_DIR/pipeline.configured.json"
echo "PASS: PDAL writer pipeline completed. Verify patch count and duplicate behavior in the target database."
