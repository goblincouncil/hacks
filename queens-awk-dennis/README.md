# queens-awk

An N-queens solver in one awk script. It prints the first solution (the column of the queen in each row) and then the total number of solutions.

    awk -v n=8 -f queens.awk
    1 5 8 6 3 7 2 4
    92

Run `sh check.sh` to test. n must be 1 to 12; anything else prints `?` and exits 1.

How it works: no recursion (awk has none that is local). An explicit array holds the column per row, and the loop advances or backtracks, testing each new queen against earlier rows by column and diagonal distance.

The check compares counts for n=1..9 with the known values (1 0 0 2 10 4 40 92 352), validates every printed board in Python, and confirms a copy with one diagonal test removed is caught.

MIT license.
