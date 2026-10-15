# rule110-sed

Rule 110, the Turing-complete cellular automaton, as one 513-byte sed script.

## Run

    { echo 0000000000000001; yes t | head -n 30; } | sed -f rule110.sed

The first input line is the starting row of 0s and 1s (width 2 or more, edges wrap around). Every later line is one tick and prints the next row, with 0 as a space and 1 as `#`. The line content after the first is ignored.

## How it works

The row lives in sed's hold space, so state survives between input lines. On a tick it is padded with its wrapped neighbours, then a loop reads the first three cells, appends the new cell after a newline, and drops one cell from the front. Eight substitutions hold the rule table. Finally the leftover padding is removed and 0/1 become space and `#`.

## Test

    sh check.sh

It compares the sed output against an independent Python Rule 110 on five random rows (widths 2 to 64, 40 ticks each), and checks the classic triangle.

MIT license.
