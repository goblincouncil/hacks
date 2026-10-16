#!/usr/bin/env python3
"""Write N random depth maps made of flat rectangles for check.sh.

usage: python3 gen_maps.py DIR N
Each mapI.txt uses dots for 0 and ragged short rows, to test padding.
mapI.txt.full is the same map as plain digits at full width, which is what
the decoder should print back.
"""
import random
import sys

out, n = sys.argv[1], int(sys.argv[2])
for i in range(n):
    rng = random.Random(i)
    w, h = rng.randint(20, 70), rng.randint(3, 12)
    grid = [[0] * w for _ in range(h)]
    for _ in range(rng.randint(1, 4)):
        x0, y0 = rng.randrange(w - 4), rng.randrange(h)
        x1, y1 = rng.randint(x0 + 4, w), rng.randint(y0 + 1, h)
        d = rng.randint(1, 9)
        for y in range(y0, y1):
            for x in range(x0, x1):
                grid[y][x] = d
    full = ["".join(map(str, r)) for r in grid]
    ragged = []
    for k, r in enumerate(full):
        s = r.rstrip("0") if k else r       # first row keeps full width
        ragged.append(s.replace("0", "."))
    with open(f"{out}/map{i}.txt", "w") as f:
        f.write("\n".join(ragged) + "\n")
    with open(f"{out}/map{i}.txt.full", "w") as f:
        f.write("\n".join(full) + "\n")
