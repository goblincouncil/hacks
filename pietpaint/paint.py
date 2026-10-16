#!/usr/bin/env python3
"""paint.py: paint text as a Piet program (P6 PPM on stdout).
usage: python3 paint.py "text" [scale] > out.ppm

Layout: a stripe of colour blocks along the top row, read left to right.
Each block is a column 1 codel wide; its height is the block's size.
Characters are built as 16*q + r, then printed with out_char.
Black under every bar keeps the pointer on the stripe. The last block is
an L that hooks under the bar before it, so every exit is black: it halts.
"""
import sys
from piet import HUES, OPS, WHITE, BLACK

OPIDX = {op: (dh, dl) for dh, row in enumerate(OPS)
         for dl, op in enumerate(row)}


def program(text):
    """list of (op, value) where push value is the block size"""
    prog = []
    for ch in text:
        n = ord(ch)
        q, r = divmod(n, 16)
        if q:
            prog += [("push", 16), ("push", q), ("mul", 0)]
            if r:
                prog += [("push", r), ("add", 0)]
        else:
            prog += [("push", max(r, 1))]
            if r == 0:
                prog += [("push", 1), ("sub", 0)]
        prog += [("out_char", 0)]
    # two harmless ops so the two bars before the last one are 1 tall,
    # which leaves room for the L-shaped halting block (see paint)
    prog += [("push", 1), ("pop", 0)]
    return prog


def paint(text):
    prog = program(text)
    # walk the colour wheel: each instruction picks the next colour.
    # block i has colour cols[i] and height sizes[i], the number a push
    # out of it would read.
    h, l = 0, 1
    cols = [(h, l)]
    sizes = []
    for op, v in prog:
        sizes.append(v if op == "push" else 1)
        dh, dl = OPIDX[op]
        h, l = (h + dh) % 6, (l + dl) % 3
        cols.append((h, l))
    sizes.append(1)  # final block, then a black wall to halt
    height = max(sizes) + 2
    width = len(cols) + 2
    img = [[WHITE] * width for _ in range(height)]
    for i, ((hh, ll), sz) in enumerate(zip(cols, sizes)):
        for y in range(sz):
            img[y][i] = HUES[hh][ll]
    # adjacent bars always differ in colour (every op changes hue or
    # lightness), so each bar is its own block. Black below each bar keeps
    # the pointer on the top row, moving right.
    last = len(cols) - 1
    for i, sz in enumerate(sizes):
        for y in range(sz, height):
            img[y][i] = BLACK
    for y in range(height):
        img[y][last + 1] = BLACK
    # halt: the last block is an L, (last,0) (last,1) (last-1,1). Its top
    # edge is (last,0), whose top is outside the image; its left edge is
    # (last-1,1), whose left is black. The bar it touches, (last-1,0), is
    # never on an exit edge, so all eight tries hit black.
    img[1][last] = img[1][last - 1] = HUES[cols[last][0]][cols[last][1]]
    return img


def ppm(img):
    h, w = len(img), len(img[0])
    return (b"P6\n%d %d\n255\n" % (w, h) +
            bytes(c for row in img for px in row for c in px))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    sys.stdout.buffer.write(ppm(paint(sys.argv[1])))
