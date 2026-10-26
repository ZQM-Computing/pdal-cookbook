#!/usr/bin/env python3
"""Write a deterministic 12-point synthetic cloud.

Columns: X Y Z Intensity. Coordinates are synthetic (a small grid near
X=100, Y=200); they describe no real place. By default the file is written
beside this script; pass an output path to keep generated artifacts isolated.
"""
import sys
from pathlib import Path

output = Path(sys.argv[1]).expanduser().resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent / "synthetic.txt"
if len(sys.argv) > 2:
    raise SystemExit("usage: generate.py [OUTPUT_PATH]")
output.parent.mkdir(parents=True, exist_ok=True)
rows = []
for i in range(12):
    x = 100 + (i % 4)
    y = 200 + (i // 4)
    z = 10 + i
    intensity = 100 + 10 * i
    rows.append(f"{x} {y} {z} {intensity}")
output.write_text("\n".join(rows) + "\n", encoding="utf-8")
print(f"wrote {output} with 12 points")
