#!/usr/bin/env python3
"""Independent sandpile: topples one cell at a time from a work stack
(the awk topples whole stacks in sweeps). By the Abelian property both
must settle to the same pile. Prints the same PPM as sandpile.awk.
usage: python3 pile.py N S"""
import sys

n, s = int(sys.argv[1]), int(sys.argv[2])
pal = ["16 12 32", "40 120 200", "240 200 60", "200 40 60"]
h = {(0, 0): n}
work = [(0, 0)]
while work:
    x, y = work.pop()
    if h.get((x, y), 0) < 4:
        continue
    h[(x, y)] -= 4
    for p in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
        h[p] = h.get(p, 0) + 1
        if h[p] >= 4:
            work.append(p)
    if h[(x, y)] >= 4:
        work.append((x, y))
e = max([max(abs(x), abs(y)) for (x, y), v in h.items() if v > 0] or [0])
w = (2 * e + 1) * s
out = ["P3", "%d %d" % (w, w), "255"]
for y in range(-e, e + 1):
    row = []
    for x in range(-e, e + 1):
        row += [pal[h.get((x, y), 0)]] * s
    line = " ".join(row)
    out += [line] * s
sys.stdout.write("\n".join(out) + "\n")
