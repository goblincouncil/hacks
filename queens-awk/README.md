# queens-awk

An N-queens solver in one awk script. It prints the first solution as a board and then the total count.

    awk -v n=8 -f queens.awk

Output ends with `n=8 solutions=92`. Bad n exits 2.

How it works: backtracking row by row. Columns and both diagonals (r+c and r-c) live in awk associative arrays used as sets, so each placement test is three lookups, and undoing is three deletes.

Test: `sh check.sh` compares counts for n=1..8 with an independent Python bitmask solver, checks the board shape, bad input, and that a copy with the anti-diagonal test removed is caught.

MIT license.
