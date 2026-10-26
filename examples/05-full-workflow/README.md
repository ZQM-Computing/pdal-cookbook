# 05 — Full Workflow: File → Pipeline → Database

**Design-only — gate 1 target. Not runtime-validated.** This pattern chains
patterns 01–04 into one end-to-end run: generate a synthetic cloud, inspect it,
sort it through a pipeline, and load it into pgPointCloud. Any step failing
aborts the run — a partial workflow is reported as failed, never as done.

## Prerequisites

- PDAL 2.10.0
- Postgres with pgPointCloud (pattern 04 prerequisites)
- Bash

## Files

- `workflow.sh` — the chain, aborting on first failure

## Steps

```bash
bash workflow.sh
```

## Expected output

- Each stage prints its check: generation (12 points), info (12 points),
  pipeline (12 points, X-sorted), database load (patches present).
- The run exits 0 only if every stage passes.
- The final database state matches pattern 04's expected output.

## Failure behavior

- Any stage failing stops the workflow (`set -euo pipefail`); later stages
  do not run against stale outputs from an earlier run. The script removes
  its intermediate outputs at start for exactly this reason.
- A database-load failure after a successful pipeline run leaves the earlier
  stages' outputs intact but the workflow failed — re-running after fixing
  the database connection re-executes the whole chain, and pattern 04's
  append-vs-replace note applies.

## Versions note / to confirm at validation

- Everything patterns 01–04 list as to-confirm, plus the chain's own question:
  the patch-count query used as the final gate, spelled against the
  validation Postgres's pgPointCloud version.
