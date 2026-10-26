#!/usr/bin/env bash
# Render the placeholder writer pipeline with explicit environment credentials.
# Credentials are written only to a temporary JSON file, never the repository.
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
export PDAL_FIXTURE="$TMP_DIR/synthetic.txt"
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
readers = [stage for stage in stages if stage.get("type") == "readers.text"]
if len(readers) != 1:
    raise SystemExit("Expected exactly one readers.text stage")
readers[0]["filename"] = os.environ["PDAL_FIXTURE"]
def conninfo(key, value):
    # libpq conninfo values use single-quoted strings with backslash escaping.
    escaped = value.replace("\\\\", "\\\\\\\\").replace("'", "\\\\'")
    return f"{key}='{escaped}'"

writer["connection"] = " ".join((
    conninfo("host", os.environ["PGHOST"]),
    conninfo("dbname", os.environ["PGDATABASE"]),
    conninfo("user", os.environ["PGUSER"]),
    conninfo("password", os.environ["PGPASSWORD"]),
))
writer["schema"] = os.environ["PGSCHEMA"]
writer["table"] = os.environ["PGTABLE"]
writer["column"] = os.environ["PGPOINTCLOUD_COLUMN"]
Path(os.environ["PDAL_OUTPUT"]).write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
PY

python3 "$DIR/../01-info/generate.py" "$TMP_DIR/synthetic.txt"
python3 -m json.tool "$TMP_DIR/pipeline.configured.json" > /dev/null
pdal pipeline "$TMP_DIR/pipeline.configured.json"
echo "PASS: PDAL writer pipeline completed. Verify patch count and duplicate behavior in the target database."
