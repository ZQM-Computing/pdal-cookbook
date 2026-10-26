#!/usr/bin/env python3
"""Write a 12-point synthetic cloud beside this script.

Columns: X Y Z Intensity. Coordinates are synthetic (a small grid near
X=100, Y=200); they describe no real place.
"""
from pathlib import Path

output = Path(__file__).resolve().parent / "synthetic.txt"
rows = []
for i in range(12):
    x = 100 + (i % 4)
    y = 200 + (i // 4)
    z = 10 + i
    intensity = 100 + 10 * i
    rows.append(f"{x} {y} {z} {intensity}")
output.write_text("\n".join(rows) + "\n", encoding="utf-8")
print(f"wrote {output} with 12 points")
