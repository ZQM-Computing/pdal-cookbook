#!/usr/bin/env bash
# Run the local file stages in an isolated temporary directory.
# Database ingestion is optional and only runs when a separately configured
# PDAL_PGPOINTCLOUD_PIPELINE path is provided by the operator.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
cp "$DIR/../03-pipeline-json/pipeline.json" "$TMP_DIR/pipeline.json"
cd "$TMP_DIR"

echo "=== stage 1: generate synthetic data ==="
python3 "$DIR/../01-info/generate.py"
mv "$DIR/../01-info/synthetic.txt" "$TMP_DIR/synthetic.txt"
# If the source example already had a generated file, do not remove it;
# generation is run in a separate temp working directory below.
