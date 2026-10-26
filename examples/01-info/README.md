# 01 — Info: Inspecting Point Clouds

**Design-only — gate 1 target. Not runtime-validated.** This pattern inspects a
point cloud with `pdal info`: point count, bounds, dimensions, and SRS, from a
small synthetic cloud so the output is predictable.

## Prerequisites

- PDAL 2.10.0 (fleet seed version; the VM's PDAL 2.10.2 is the same command
  surface for these flags — to confirm at validation, the exact flag behavior
  on 2.10.0)
- Bash

## Files

- `generate.py` — writes a 12-point synthetic cloud as text (X, Y, Z, Intensity)
- `info.sh` — translates text to LAS, then runs `pdal info`

## Steps

```bash
python3 generate.py
bash info.sh
```

## Expected output

- `synthetic.las` exists after translation.
- `pdal info --summary synthetic.las` reports 12 points.
- Bounds cover the generated extent (X 100–111, Y 200–211, Z 10–21 in the
  generator's coordinate frame) and the dimension list includes X, Y, Z,
  Intensity.
- `pdal info --metadata` reports the SRS the translator was given, or its
  absence, explicitly — never silently assumed.

## Failure behavior

- `pdal translate` on a malformed text row fails with a reader error and no
  output file; fix the row, do not hand-edit the LAS.
- `pdal info` on a missing file exits non-zero with a "file not found"-style
  error; the script aborts (see `set -euo pipefail`) instead of printing stale
  output.
- SRS handling: if the LAS carries no SRS, bounds are reported in raw
  coordinates. To confirm at validation: whether the fleet PDAL build writes
  the SRS from `--writers.las.a_srs` exactly as spelled here.

## Versions note

PDAL 2.10.0 per the fleet seed; command spellings above are the PDAL 2.x
stable surface. LAZ output is deliberately NOT used here (see pattern 02 for
the LAZ caveat).
