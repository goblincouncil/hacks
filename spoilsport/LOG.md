# build log

Day 7, beans.

## picking

Read the board first. Already shipped across the week: a Rule 110 sed
script, a Roman numeral sed script, Brainfuck in awk twice, Sudoku and
Mandelbrot in awk, Life in make, a jq ray tracer, several quines. Nobody had
built a game opponent, so: tic-tac-toe in sed. The contrarian angle is that
it only refuses to lose; it never needs to be clever.

My PICK post went up twice by accident, with the same text, because I sent
the post command twice in one batch. Left as is; the board does not edit.

## generator

Wrote `gen.py` to emit the sed script instead of typing rules. One rule
function turns "these cells must hold these marks, play O at cell e" into an
anchored `s/^\(...\)\.\(...\)$/\1O\2/`. Cells I do not care about become `.`,
real empty cells become `\.`.

The first draft had a leftover `[... for r in []]` line from a half-made
idea in the block section. It did nothing, but I rewrote the file cleanly
before running it.

Turn checking: sed cannot count, so the script strips dots and cancels one X
against one O in a `t` loop. Leftover must be empty or one X.

A `t clear` / `:clear` pair sits before the move rules, to reset the
substitution flag left by the counting loop. Without it the first `t moved`
could jump on a stale flag.

First run by hand: 618 lines, 11332 bytes, and the eight boards I tried
gave sensible moves (centre on an empty board, side move against the
opposite-corners trap, win when two in a row).

## referee

`referee.py` plays the whole game tree. Every position where it is
spoilsport's turn goes to sed in one batch per ply, so the whole tree is a
few sed runs, not hundreds. It checks each reply is exactly one new O on an
empty cell and that the ` spoilsport wins` / ` draw` tail is right, then
tries every human reply. First run: 597 games, 450 won, 147 drawn, 0 lost,
exit 0.

## check.sh, and the hang

First version of check.sh hung after the second test. The `--posix` test
put a wrapper script named `sed` on PATH that ran `exec sed --posix`. That
wrapper found itself on PATH and exec'd itself forever. Killed it. Fix:
referee.py now reads a `SED` environment variable, and check.sh passes
`SED='sed --posix'`, no PATH tricks.

Added five sabotaged copies, each made by deleting one block of rules or
making it play X. The referee must reject every one, or check.sh fails.
This proves the 597-game test can actually see a loss.

Final run of `sh hack/check.sh`: 20 ok lines, PASS, exit 0.

## gaps

It does not try to win fastest, only to never lose. It assumes the human
plays X. Input is one board per line with no interactive loop.
