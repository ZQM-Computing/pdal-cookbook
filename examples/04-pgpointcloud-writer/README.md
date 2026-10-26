# 04 — pgPointCloud Writer: Patches into Postgres

**Design-only — gate 1 target. Not runtime-validated.** This pattern writes a
point cloud into pgPointCloud as patches: one pipeline, `writers.pgpointcloud`,
against a Postgres database with the pgPointCloud extension. It is the PDAL
half of the PDAL → pgPointCloud → GeoServer → TiTiler chain.

## Prerequisites

- PDAL 2.10.0
- Postgres with PostGIS and the pgPointCloud extension installed
  (see pgpointcloud-cookbook)
- A database connection available to PDAL — connection values come from the
  environment, never from a committed file; the pipeline below uses
  placeholders
- Bash

## Files

- `pipeline.json` — readers.text → writers.pgpointcloud (placeholder
  connection settings)

## Steps

```bash
# Set PGCONNECTION (or the writer's connection options) from your environment,
# fill in the placeholders in pipeline.json, then:
pdal pipeline pipeline.json
```

## Expected output

- The pipeline completes with no writer error.
- The target table holds patches covering the 12 synthetic points (query the
  patch count and the point count through pgPointCloud's patch functions —
  exact function names to confirm at validation).
- Re-running the pipeline does not silently duplicate patches: the expected
  behavior (append vs replace) is whatever the writer's table handling is
  configured to do, and must be stated before the second run.

## Failure behavior

- Missing pgPointCloud extension: the writer fails at connection/setup with an
  extension error. Install the extension first; do not point the writer at a
  plain PostGIS table and expect patches.
- Wrong connection values: the writer fails at connect, before any points are
  written; no partial patches are expected, but verify the table is empty
  before retrying.
- Schema/table/column spellings: the writer option names in `pipeline.json`
  are placeholders for the PDAL 2.10.0 `writers.pgpointcloud` options.

## Versions note / to confirm at validation

- The exact `writers.pgpointcloud` option names (connection, schema, table,
  patch column, compression, capacity) against PDAL 2.10.0.
- The pgPointCloud extension version on the validation Postgres, and the
  patch-count / point-count query spellings.
- The validation node: fleet pgPointCloud work is blocked on Node-4 Postgres
  auth, so the gate-3 node choice is open (see the pgpointcloud-cookbook
  plan).
