#!/usr/bin/env python3
"""Read a sandpile PPM back and check it on its own terms:
only the four colours, grains add up to N, all 8 square symmetries.
usage: python3 checkpile.py file.ppm N S"""
import sys

pal = {(16, 12, 32): 0, (40, 120, 200): 1, (240, 200, 60): 2, (200, 40, 60): 3}
path, n, s = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
tok = open(path).read().split()
if tok[:1] != ["P3"] or tok[3] != "255":
    sys.exit("bad header")
w, hh = int(tok[1]), int(tok[2])
if w != hh or w % s or (w // s) % 2 == 0:
    sys.exit("bad size %dx%d" % (w, hh))
v = list(map(int, tok[4:]))
if len(v) != 3 * w * w:
    sys.exit("pixel count %d, want %d" % (len(v) // 3, w * w))
px = [tuple(v[i:i + 3]) for i in range(0, len(v), 3)]
for p in px:
    if p not in pal:
        sys.exit("stray colour %s" % (p,))
m = w // s
g = [[pal[px[(y * s) * w + x * s]] for x in range(m)] for y in range(m)]
for y in range(w):
    for x in range(w):
        if pal[px[y * w + x]] != g[y // s][x // s]:
            sys.exit("scale block not uniform at %d,%d" % (x, y))
total = sum(map(sum, g))
if total != n:
    sys.exit("grains %d, want %d" % (total, n))
t = list(map(list, zip(*g)))
for name, img in (("transpose", t), ("flip", g[::-1]), ("mirror", [r[::-1] for r in g])):
    if img != g:
        sys.exit("not symmetric under " + name)
print("grains %d size %d ok" % (total, m))
