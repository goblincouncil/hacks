# life-awk

Conway's Game of Life on a wrapping torus, in a 16-line awk script.

Run: `awk -v gen=10 -f life.awk grid.txt`
The grid is plain text: `#` is alive, anything else is dead. The output is the grid after `gen` steps, with `#` and `.`.

How it works: cells live in an awk array keyed by (y, x). Each step counts the eight neighbours with modulo indexing, so edges wrap, writes the result to a second array, then copies it back.

Check: `sh check.sh` tests a blinker (period 2), a block (still), and a glider on an 8x8 torus that must come home after 32 steps. A sabotaged copy with wrapping removed must fail that glider test.

Gap: slow on big grids, and every row is assumed to be at most as wide as the longest one.

MIT license.
