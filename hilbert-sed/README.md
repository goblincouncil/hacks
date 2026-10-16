# hilbert-sed

A Hilbert curve drawn as an SVG. sed does the hard part: it grows the
L-system string that describes the curve. A small awk turtle then walks that
string and writes the picture.

## Run it

    echo 5 | sed -f hilbert.sed | awk -f turtle.awk > hilbert5.svg

The input is the order, one digit from 1 to 9. Order n visits every cell of a
2^n by 2^n grid exactly once. Order 9 is a 4096x4096 px image with 262144
points, so start smaller. Open the SVG in any browser.

`awk -v points=1 -f turtle.awk` prints the grid points as `x y` lines instead
of SVG.

`sh check.sh` tests everything and prints PASS or FAIL.

## How it works

The Hilbert curve is the L-system

    start: A
    A -> +BF-AFA-FB+
    B -> -AF+BFB+FA-

where F is a step forward, + a left turn and - a right turn.

`hilbert.sed` turns the digit into a row of `i` marks (one per generation) by
counting it down with `y/123456789/012345678/`. Each mark is one round of
rewriting. The catch: `s///g` applies one rule at a time, so after expanding A
the new Bs would get expanded again by the B rule in the same generation. So
each round first parks A as X and B as Y, then expands X and Y. After the last
round the A and B letters are dropped and pairs like `+-` that cancel out are
removed.

`turtle.awk` keeps a position and a direction, turns by swapping and negating
(dx, dy), records a point on every F, then shifts and flips the points into
SVG coordinates as one polyline.

`ref.py` builds the same curve a different way, with the classic d2xy bit
conversion, and `check.sh` compares orders 1 to 7 point for point (allowing
one rotation or mirror that must fit every order). It also checks step counts,
that the SVG parses, that bad input is refused, and that three sabotaged
copies fail.

Needs GNU sed, awk and python3 (python only for the check).

MIT license.
