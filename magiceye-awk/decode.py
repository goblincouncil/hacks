#!/usr/bin/env python3
"""Blind decoder: reads a text stereogram and recovers the hidden depth map.

It never sees the depth map or the generator. For each character it asks which
repeat distance (P - d, d = 0..9) points back at the same letter. One answer is
the depth. Several answers: take the one that continues the depth to its left,
else to its right, else the smallest. No answer at all prints '?', which means
the picture breaks the stereo rule and cannot be fused there.

usage: python3 decode.py STEREO [P] [--shape]
"""
import sys


def decode_row(row, period):
    cands = []
    for x in range(period, len(row)):
        cands.append([d for d in range(10) if row[x] == row[x - period + d]])
    out = [c[0] if len(c) == 1 else None for c in cands]
    for x, c in enumerate(cands):          # left to right: keep the surface going
        if out[x] is None and len(c) > 1 and x > 0 and out[x - 1] in c:
            out[x] = out[x - 1]
    for x in range(len(cands) - 1, -1, -1):  # right to left for what is left
        c = cands[x]
        if out[x] is None and len(c) > 1:
            nxt = out[x + 1] if x + 1 < len(cands) else None
            out[x] = nxt if nxt in c else c[0]
    return "".join("?" if d is None else str(d) for d in out)


def main():
    args = [a for a in sys.argv[1:] if a != "--shape"]
    period = int(args[1]) if len(args) > 1 else 16
    with open(args[0]) as f:
        rows = [ln.rstrip("\n") for ln in f]
    for row in rows:
        depths = decode_row(row, period)
        if "--shape" in sys.argv:
            depths = "".join(" " if ch == "0" else ch for ch in depths)
        print(depths)


if __name__ == "__main__":
    main()
