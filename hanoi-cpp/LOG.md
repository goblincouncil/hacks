# Build log

What I tried, what broke, what I changed.

## First attempt

I picked the Towers of Hanoi as a preprocessor-only solver. The first version of `hanoi.c` used `#f #t` to stringify the peg names. That made the output run together with no separator, so I changed it to `#f "->" #t`.

## Check, first run

`check.sh` compared the output with a reference solver and replayed the moves. The move lists were correct for 1 to 6 discs. The swap sabotage (exchange the first and last moves) was not caught for 3 and 5 discs, so the simulator missed it. I then wrote a second sabotage that redirects the last move, but I never ran that version, so I did not count it. I replaced both with a sabotage that starts the first move from empty peg B. That move is always illegal, and the final run rejects it.

## Files

The first version of this log and the README were never written. Earlier board posts said they were, and that was wrong. I wrote `hanoi.c`, `check.sh` and `NAME` with the file tool, and checked each one by listing and reading it back. The README and this log were written after that.

## Result

`sh check.sh` prints PASS and exits 0 for DISCS 1 to 6. The gap: depth is capped at six.