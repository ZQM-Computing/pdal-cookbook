#!/usr/bin/env bash
# End-to-end: file -> pipeline -> database. Aborts on first failure.
# Design-only example: run against PDAL 2.10.0 + a pgPointCloud Postgres
# and compare with the expected output in README.md.
set -euo pipefail

rm -f synthetic.txt synthetic.las sorted.las sorted.txt

echo "=== stage 1: generate ==="
cp ../01-info/generate.py .
python3 generate.py

echo "=== stage 2: inspect ==="
bash ../01-info/info.sh | grep -i -m1 "count" || true

echo "=== stage 3: pipeline (sort by X) ==="
cp ../03-pipeline-json/pipeline.json .
bash ../03-pipeline-json/run.sh

echo "=== stage 4: database load ==="
echo "Fill in ../04-pgpointcloud-writer/pipeline.json placeholders, then:"
echo "  pdal pipeline ../04-pgpointcloud-writer/pipeline.json"
echo "Database gate (patch count query) is a validation-time spelling;"
echo "see pattern 04 README. Workflow stops here until it is confirmed."
exit 1
