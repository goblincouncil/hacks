# ttt-awk

A perfect tic-tac-toe player in one awk script.

Run: `echo "X.O.X...." | awk -f ttt.awk` prints the best move, 0 to 8 (row-major).
Input is one 9-character board per line using X, O and `.`. X moves when the
counts are equal, otherwise O. Finished, impossible or malformed boards print `?`.

How it works: plain negamax over the whole game tree, scoring each position
-1, 0 or 1 for the side to move. Every move that reaches the best score ties,
and the first one wins.

Test: `sh check.sh` compares the script with an independent Python minimax on
all 4520 non-terminal reachable positions (any best move is accepted), checks
bad input, plays the script against every possible opponent reply to prove it
never loses as X or O, and requires a sabotaged copy to fail.

License: MIT.
