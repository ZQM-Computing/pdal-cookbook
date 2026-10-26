# 03 — Pipeline JSON: Writing and Running PDAL Pipelines

**Design-only — gate 1 target. Not runtime-validated.** This pattern runs a
three-stage PDAL pipeline from JSON: read text, sort by X, write LAS. Pipeline
JSON is the repeatable form of PDAL work — the same file runs on any machine
with the same PDAL version.

## Prerequisites

- PDAL 2.10.0
- The synthetic cloud from pattern 01 (`synthetic.txt`)
- Bash

## Files

- `pipeline.json` — readers.text → filters.sort → writers.las
- `run.sh` — runs the pipeline and checks the output

## Steps

```bash
bash run.sh
```

## Expected output

- `sorted.las` exists after the run.
- `pdal info --summary sorted.las` reports 12 points.
- Points in `sorted.las` are ordered by ascending X (verify by translating back
  to text and reading the first column, as `run.sh` does).

## Failure behavior

- A JSON syntax error fails fast at pipeline parse with a JSON error, before
  any stage runs; validate with a JSON parser first (`python3 -m json.tool`).
- An unknown stage type (typo in `filters.sort`) fails at pipeline
  construction with a stage-lookup error; the stage names in `pipeline.json`
  are the PDAL 2.x canonical names — to confirm at validation against PDAL
  2.10.0's stage registry.
- If the input file is missing, the reader stage fails and no output file is
  written; the script aborts instead of reporting a stale `sorted.las`.

## Versions note

PDAL 2.10.0 per the fleet seed. Pipeline JSON schema is version-stable across
PDAL 2.x for these three stage types; any 2.10.0 deviation is a validation
finding, not a silent edit.
