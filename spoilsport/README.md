# spoilsport

A tic-tac-toe opponent that never loses, written as one sed script. Every
move it makes is a single regex substitution on the board.

## Run it

A board is one line of nine characters, read across the rows from the top
left: `.` is empty, `X` is you, `O` is spoilsport. Give it a board where it
is its turn and it prints the board after its move.

    $ echo X........ | sed -f spoilsport.sed
    X...O....
    $ echo X...O...X | sed -f spoilsport.sed
    XO..O...X
    $ echo OO.XX.... | sed -f spoilsport.sed
    OOOXX.... spoilsport wins

An empty board `.........` lets it open. It adds ` draw` when its move fills
the board. Anything it will not play gets a line starting with `?`: not a
board, not my turn, you already won, I already won, board full.

It reads one board per line, so you can feed it a whole file of positions.

## Test it

    sh check.sh

Needs GNU sed and python3. The check rebuilds the script from `gen.py`,
then `referee.py` plays every possible human game against it (you opening on
any of the nine cells, and spoilsport opening): 597 games, spoilsport wins
450 and draws 147, and the human wins none. It runs the same tree again
under `sed --posix`, tests refusals, and makes five broken copies of the
script (no blocking, no fork defence, and so on) to prove the referee would
notice a loss.

## How it works

`spoilsport.sed` is 618 lines and 11332 bytes, with 239 substitutions. It is
written by `gen.py`, because nobody should type 239 of these by hand.

First it checks the input. Counting X and O in sed has no arithmetic, so it
deletes the dots and then cancels one X against one O in a loop until
nothing pairs up. What is left must be empty or one X, or it is not its turn.

Then it walks the classic priority list, one block of rules each: win, block,
fork, a side move when you hold opposite corners around its centre, take the
cell where you would fork, centre, the corner opposite yours, any corner,
any side. Each rule is an anchored pattern of the whole board, like

    s/^\(X...\)\.\(...X\)$/\1O\2/

which says: if cell 0 and cell 8 are X and cell 4 is empty, put an O in the
middle. After every rule a `t moved` jumps out on the first one that fired,
so rule order is the strategy. Nothing in the script knows about rows or
lines; they live only in which dots are literal and which are wildcards.

MIT License.
