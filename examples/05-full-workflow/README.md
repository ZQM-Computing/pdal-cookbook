# 05 — Full Workflow: File → Pipeline → Database

**Design-only — not runtime-validated.** This script runs the local file stages in an isolated temporary directory: generate a synthetic cloud, verify its point count, sort it through the PDAL JSON pipeline, and verify ascending X order. The database stage is skipped unless `PDAL_PGPOINTCLOUD_PIPELINE` points to a separately configured writer pipeline.

## Prerequisites

- PDAL 2.10.0
- Optional: Postgres with pgPointCloud and an operator-configured writer pipeline (pattern 04 prerequisites)
- Bash

## Files

- `workflow.sh` — isolated local-stage workflow; optionally runs a separately configured database pipeline

## Steps

```bash
bash workflow.sh
```

## Expected output

- The local stage checks 12 generated points and ascending X order.
- The run exits 0 if every stage it executes passes.
- Without `PDAL_PGPOINTCLOUD_PIPELINE`, it prints an explicit `SKIP` for database ingestion; that does not certify the full database workflow.

## Failure behavior

- Any stage failing stops the workflow (`set -euo pipefail`). Outputs are isolated in a fresh temporary directory and removed on exit; caller files are not deleted.
- A database-load failure after a successful pipeline run leaves the earlier
  stages' outputs intact but the workflow failed — re-running after fixing
  the database connection re-executes the whole chain, and pattern 04's
  append-vs-replace note applies.

## Versions note / to confirm at validation

- Everything patterns 01–04 list as to-confirm, plus the chain's own question:
  the patch-count query used as the final gate, spelled against the
  validation Postgres's pgPointCloud version.
