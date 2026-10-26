#!/usr/bin/env python3
"""Write a 12-point synthetic cloud as whitespace-delimited text.

Columns: X Y Z Intensity. Coordinates are synthetic (a small grid near
X=100, Y=200); they describe no real place.
"""
rows = []
for i in range(12):
    x = 100 + (i % 4)
    y = 200 + (i // 4)
    z = 10 + i
    intensity = 100 + 10 * i
    rows.append(f"{x} {y} {z} {intensity}")
with open("synthetic.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(rows) + "\n")
print("wrote synthetic.txt with 12 points")
