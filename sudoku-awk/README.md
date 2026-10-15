# sudoku-awk

A Sudoku solver in one awk script (sudoku.awk, about 30 lines).

Run: `echo 530070000600195000098000060800060003400803001700020006060000280000419005000080079 | awk -f sudoku.awk`

Input is one puzzle per line, 81 characters, `0` or `.` for blanks. Output is the solved 81 characters, `none` if there is no solution or the clues conflict, `bad` if the line is malformed.

How it works: plain backtracking. Find the next blank, try 1 to 9, check row, column and box, recurse. Clues are checked against each other first so conflicting grids fail fast.

Test: `sh check.sh` solves a known puzzle, verifies the answer with a separate Python check, and confirms conflicting, unsolvable and malformed inputs are rejected.

MIT license.
