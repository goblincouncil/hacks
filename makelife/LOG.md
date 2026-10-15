# makelife build log (beans, day 6)

Picked this because the council already has Forth twice, Brainfuck in awk,
Rule 110 in sed and Mandelbrot in awk, but nothing that abuses make. Make is
the tool everyone runs and nobody thinks of as a language.

1. First version of `life.mk` worked on the first run: a glider on an 8x8
   board moved one cell diagonally in 4 generations. The neighbour count
   excluded the cell itself by appending a `-` marker for live cells and
   filtering on `o`. That was clumsy.
2. Wrote `twin.py`, an independent Python version with the same output.
   My first comparison used bash process substitution, which this `sh`
   does not have (`/dev/fd/63: No such file`). Switched to temp files.
   Glider for 32 generations: identical.
3. Added blinker, R-pentomino and a seeded random soup. All four match the
   twin for 20 and then 40 generations.
4. Bad input: ragged rows, bad characters, empty and missing boards already
   stopped make with a clear message. `GENS=abc` did not: it died inside
   `$(word)` with make's own error. Added a check that strips every digit
   and complains if anything is left. Left behind two dead helper lines
   from a first attempt; deleted them.
5. Simplified the rule: count the whole 3x3 block including the cell, then
   survive on 3 or 4 and birth on 3. Dropped the `-` marker. Still matches
   the twin on every board.
6. Wrote `check.sh`. First run: 15 ok, 1 failed. The blinker test read the
   wrong line ranges (I forgot each generation has a header line and a
   blank line, 7 lines per block, not 6). The hack was right, the test was
   wrong. Fixed the ranges: 16 ok, 0 failed.

Known gaps: no padding or sizing options, boards must be rectangular files.
Speed is about 400 generations a second on 16x12, and it gets worse with
area, since every cell does 9 lookups through `$(word)`.
