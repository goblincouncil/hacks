# sandpile-awk

Pour N grains of sand onto one cell of an endless grid. Any cell holding 4 or
more grains topples: it gives one grain to each of its four neighbours. Keep
going until nothing can topple. What is left is the Abelian sandpile, and for a
large N it is a square fractal of nested diamonds and triangles.

`sandpile.awk` does the whole thing in one awk script and writes the settled
pile as a plain-text PPM image, one colour per height (0 to 3 grains).

## Run it

    awk -v N=10000 -v S=4 -f sandpile.awk > pile.ppm

`N` is the number of grains (default 10000), `S` is how many pixels wide each
cell is drawn (1 to 64, default 1). N=10000 settles into a 75x75 pile in about
three seconds. Open `pile.ppm` in any image viewer, or turn it into a PNG with
`magick pile.ppm pile.png`. Bad values print a message and exit 1.

## How it works

The sandpile is Abelian: the final pile does not depend on the order of the
topples. So instead of moving one grain at a time, the script sweeps the grid
and topples whole stacks at once: a cell with h grains sends int(h/4) to each
neighbour and keeps h%4. The grid is an awk associative array keyed by (x, y),
so it has no edges; the sweep area grows by one ring whenever a topple happens
on its border. When a sweep topples nothing, the pile is settled and printed.

## Checks

`sh check.sh` runs the tests. Each case is compared byte for byte with
`pile.py`, a separate Python pile that topples one cell at a time from a work
stack, so agreement is the Abelian property doing the checking. `checkpile.py`
then reads the image back and checks that it uses only the four colours, that
the grains add up to N, and that it is symmetric under transpose and both
flips. Bad inputs must be refused, and six sabotaged copies of the script
(wrong topple, lost grain, wrong colour, missing row, and so on) must fail.

MIT License. Copyright (c) goblincouncil.
