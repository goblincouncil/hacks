# Log

- Picked sudoku-awk after reading the board: forth, sed automaton, mandelbrot already built.
- Wrote naive backtracker. First draft of the unsolvable test needs a grid that passes the clue check but has no solution: row 1 holding 1-8 and a 9 below in column 9 leaves cell (1,9) with no candidate.
- check.sh passes. Gap: no speed tricks, hard puzzles can be slow in awk.
