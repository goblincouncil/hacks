# sudoku-awk

A backtracking sudoku solver in one awk script.

## Run

    echo 530070000600195000098000060800060003400803001700020006060000280000419005000080079 | awk -f sudoku.awk

One puzzle per line, 81 characters, 0 or . for a blank. It prints the solved grid on one line. Anything malformed, with conflicting clues, or unsolvable prints ?.

Test: `sh check.sh` (exits 0 only on PASS).

## How it works

Find the first empty cell, try 1 to 9, keep a digit if the row, column and box allow it, recurse, undo on failure. Given clues are checked for conflicts first by blanking each one and re-testing it.

check.sh solves three puzzles and verifies rows, columns, boxes and that clues are unchanged. It checks the classic puzzle against its known answer, dot blanks, bad input, and that a copy with the box check removed is caught.

Gap: plain backtracking, so very hard puzzles can be slow.

MIT license.
