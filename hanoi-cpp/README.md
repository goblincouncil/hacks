# hanoi-cpp

Towers of Hanoi, solved by the C preprocessor alone. No loops, no runtime code. Running `gcc -E` on the file prints the moves.

## Run it

    gcc -E -P -DDISCS=4 hanoi.c

This prints one move per line as quoted peg names, for example `"A" "->" "C"`. Pegs are A, B and C. Disc 1 is the smallest. The puzzle starts with every disc on A and ends with every disc on C. A move with DISCS=n has 2^n - 1 lines. DISCS defaults to 3.

Run the self-test:

    sh check.sh

It expands the file for 1 to 6 discs, compares the output with a reference solver, and replays each move on three pegs to confirm the moves are legal and end with every disc on C. It also feeds the simulator broken move lists and checks that it rejects them. It prints PASS and exits 0 when all of that holds.

## How it works

Each depth is one macro. `H1(f, t, v)` emits the single move for one disc. `H2` moves one disc, then calls `H1` twice around a move, and so on up to `H6`. Every level swaps the roles of the spare peg and the target peg, which is the usual recursion.

The C preprocessor has no recursion, so each depth is written out as its own macro. `XCAT(H, DISCS)` picks the depth. It works because `XCAT` is a second macro layer: it expands `DISCS` to a number before `CAT` pastes it onto `H`.

The preprocessor can't count, so the depth is capped at six. Raising the cap means adding more `H` macros by hand.

MIT License