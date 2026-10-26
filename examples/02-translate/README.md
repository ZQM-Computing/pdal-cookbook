# 02 — Translate: LAS, LAZ, and Text Formats

**Design-only — gate 1 target. Not runtime-validated.** This pattern moves one
small cloud between LAS, LAZ, and text with `pdal translate`, and checks the
round trip preserves the point count.

## Prerequisites

- PDAL 2.10.0
- The synthetic cloud from pattern 01 (`synthetic.txt` + `synthetic.las`), or
  regenerate it with `01-info/generate.py`
- Bash

## Files

- `translate.sh` — LAS → LAZ, LAZ → text, and count checks

## Steps

```bash
cd examples/01-info
python3 generate.py
bash info.sh
cd ../02-translate
bash translate.sh
```

## Expected output

- `synthetic.laz` is created in this pattern's directory. File size is not
  asserted because compression ratio depends on the input and writer settings.
- The LAZ → text step reproduces 12 data rows.
- The script parses the PDAL summary JSON and asserts 12 source points, equal
  LAS/LAZ point counts, and an equal number of non-empty round-trip text rows.

## Failure behavior

- If the PDAL build lacks LAZ support, the LAS → LAZ step fails at the writer
  with a compression error. That is a build-capability result, not a data
  error: record it, do not work around it by renaming files.
- A count mismatch after the round trip means the translation is lossy or the
  wrong file was compared; stop and diff the two text outputs row by row.

## Versions note / to confirm at validation

- Whether the fleet PDAL 2.10.0 build (QGIS-bundled) includes LAZ read/write
  support. The seed records PDAL 2.10.0 with the QGIS stack and a LAZ-verified
  PDAL 2.10.2 on the VM — the 2.10.0 LAZ capability is the open item.
- Whether `pdal translate` output ordering is stable for this input (the count
  check does not depend on order; a row-diff check would).
