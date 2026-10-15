# makelife

Conway's Game of Life written entirely in GNU Make. No recipe ever runs and
no shell is ever started: the whole simulation happens while make is still
reading the makefile.

## Run it

    make -s -f life.mk BOARD=boards/glider.txt GENS=4

A board is a text file of `.` (dead) and `#` (alive), one row per line, all
rows the same width. The board wraps around at the edges (a torus). Output is
each generation with its population:

    generation 1, population 5
    ........
    ........
    .#.#....
    ..##....
    ..#.....

Bad input stops make with exit code 2 and a message starting `makelife:`
(ragged rows, characters other than `.` and `#`, an empty or missing board,
a GENS that is not a whole number).

Sample boards: `glider`, `blinker`, `rpentomino`, and `soup` (a random 16x12
board, seeded so it is the same every time).

## How it works

Make has no numbers, no arrays and no loops in the usual sense. It has
variables, string functions and `$(foreach)`. That turns out to be enough.

- Each cell is a variable `c.X.Y`. A live cell holds the word `o`; a dead
  cell is empty.
- Counting neighbours is `$(words ...)` over the 3x3 block. Empty variables
  expand to nothing, so dead cells simply vanish and the word count is the
  number of living cells. The block includes the cell itself, so the rule
  becomes: a live cell survives if the count is 3 or 4, a dead cell is born
  if the count is 3.
- Numbers 1..N are built by appending one word at a time until the list has
  N words. `$(words x $(list))` is the increment.
- Wrapping edges: "next x" and "previous x" are word lists rotated by one, so
  the neighbour of column 8 on an 8-wide board is just word 8 of `2 3 4 5 6 7
  8 1`.
- A step computes every cell into `n.X.Y` with `$(eval)`, then copies them
  all back into `c.X.Y`, so updates never see half a generation.
- The board is read with `$(file <...)`, which needs GNU Make 4.2 or later.

`twin.py` is an independent Python Game of Life with the same output format.
`check.sh` runs every sample board for 40 generations through both and
compares the output byte for byte, with `SHELL=/bin/false` so any hidden
shell call would fail. It also checks facts that do not depend on the twin
(a glider on an 8x8 torus comes home after 32 generations, a blinker has
period 2), feeds it eight kinds of bad input, and breaks the birth rule on
purpose to make sure the comparison notices.

    sh check.sh

It is slow in the way you would expect: a 16x12 board runs about 400
generations a second.

MIT License. Copyright (c) 2026 goblincouncil.
