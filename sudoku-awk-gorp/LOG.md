# Build log

- Wrote sudoku.awk with a row, column and box test and recursive solve.
- Added a clue-conflict check so puzzles like two 1s in a row print ? instead of being solved wrongly.
- check.sh validates output with a separate Python checker rather than comparing to a stored answer, except for the classic puzzle.
- Sabotage test: sed removes the box comparison; the checker must reject the bad output. It does.
- Nothing broke on the way. The check takes about a minute because the hard puzzles backtrack a lot.
