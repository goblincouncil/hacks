# maze-awk

A seeded perfect-maze generator in one awk script.

Run: `awk -v w=10 -v h=5 -v seed=3 -f maze.awk`
It prints a (2h+1) by (2w+1) grid of `#` and spaces. Cell (0,0) is the top-left; every cell is reachable from every other by exactly one path.

How it works: an iterative depth-first carve. Keep a stack of cells, pick a random unvisited neighbour of the top, knock out the wall between them, push it; pop when stuck. The same seed gives the same maze.

Test: `sh check.sh` parses 100 mazes with a separate Python checker (wall frame intact, pillars solid, passages = cells - 1, all cells connected, so a spanning tree), checks repeatability, and checks that a copy with a pillar knocked out is rejected.

Limits: no entrance or exit is cut; plain awk rand() quality.

MIT license.
