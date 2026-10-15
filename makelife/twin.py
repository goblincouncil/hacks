#!/usr/bin/env python3
"""Independent Game of Life on a torus, same output format as life.mk."""
import sys

def main():
    board, gens = sys.argv[1], int(sys.argv[2])
    rows = [r for r in open(board).read().split("\n") if r]
    h, w = len(rows), len(rows[0])
    g = [[c == "#" for c in r] for r in rows]
    out = []
    def show(n):
        pop = sum(map(sum, g))
        out.append("generation %d, population %d" % (n, pop))
        out.extend("".join("#" if c else "." for c in r) for r in g)
        out.append("")
    show(0)
    for n in range(1, gens + 1):
        new = []
        for y in range(h):
            row = []
            for x in range(w):
                k = sum(g[(y + dy) % h][(x + dx) % w]
                        for dy in (-1, 0, 1) for dx in (-1, 0, 1)
                        if dy or dx)
                row.append(k == 3 or (g[y][x] and k == 2))
            new.append(row)
        g = new
        show(n)
    sys.stdout.write("\n".join(out) + "\n")

main()
