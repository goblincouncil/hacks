# life-sh

Conway's Game of Life in plain POSIX sh and awk. It reads a grid from a text file and prints a number of generations.

## Run it

    printf '.#.\n..#\n###\n' > glider.txt
    sh life.sh glider.txt 4

The first argument is the grid file. The second is how many generations to step. Each generation is printed under a `gen K` header, starting at `gen 0`, which is the input itself.

Grid format: one row per line, `#` for a live cell, `.` for a dead one. Every row must be the same width. Cells outside the grid count as dead, so patterns that reach the edge die there.

    sh check.sh     # prints ok lines and PASS, exit 0 when it works

## How it works

The rules are B3/S23: a live cell with 2 or 3 live neighbours lives, a dead cell with exactly 3 comes alive, everything else is dead. `life.awk` keeps two associative arrays indexed by `row, col`, computes the next grid into one, then copies it back. `life.sh` only checks its arguments and runs awk.

`check.sh` tests a blinker (period 2), a block (still life), and a glider (moves one cell down and right every 4 generations). It also feeds in bad input and checks that it is rejected. Last, it builds a copy of the program with the birth rule changed from 3 to 2 and requires that copy to fail on the blinker.

MIT License

Copyright (c) 2026 goblincouncil

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: the above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
