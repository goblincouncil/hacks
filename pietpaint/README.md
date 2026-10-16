# pietpaint

Paint any text as a Piet program, then run the painting to get the text back.

Piet is a programming language where the program is a picture. The
interpreter does not look at colours themselves, only at how the colour
changes from one block to the next: a step around the hue wheel and a step
in lightness together pick one of 17 instructions. The size of the block you
leave is the number a `push` puts on the stack.

This directory has three small stdlib Python files:

- `paint.py` turns text into a Piet program and writes it as a P6 PPM image.
- `piet.py` is a Piet interpreter that runs a PPM image.
- `frame.py` blows a painting up so you can see it, or previews it in a
  terminal with 24-bit colour.

## Run it

    python3 paint.py "goblincouncil" > g.ppm
    python3 piet.py g.ppm                 # prints goblincouncil
    python3 frame.py g.ppm 12 > big.ppm   # 12x bigger, open in any viewer
    python3 piet.py -c 12 big.ppm         # the big one runs too
    python3 frame.py g.ppm                # look at it in the terminal

    sh check.sh                           # the test, prints PASS on success

## How it works

`paint.py` writes each character as `16*q + r`: push 16, push q, multiply,
push r, add, out_char. That keeps every number small, so no block is taller
than 16 codels. Then it walks the colour wheel: start on red, and for each
instruction take the hue and lightness step that encodes it. Every block is
one column wide and as tall as the number it should push, so the painting
reads as a strip of coloured bars of different heights, like a bar chart of
the message. Black is painted under each bar so the pointer can only move
right along the top row.

Stopping is the fiddly part. A Piet program halts when the pointer tries all
eight ways out of a block and every one is black or the image edge. The last
block always touches the bar before it, so a one-codel last block just walks
back. Instead the last block is a small L that hooks under the bar before
it. Exits only leave from a block's furthest edge, and the codel that
touches the previous bar is never on one, so the program stops.

`goblincouncil` becomes 80 instructions and an 83x18 image.

`piet.py` follows the usual Piet rules: direction pointer and codel chooser,
exit codel chosen from the furthest edge, eight tries against black before
it halts, sliding straight through white without running anything, and the
quiet rules for bad stack operations (division by zero, short stacks, bad
roll depth are ignored). `-c` sets the codel size and `-n` caps the steps.

`check.sh` paints 28 texts (fixed and random, all 7-bit, including the empty
string and control characters) and runs each back; runs a 7x blown-up copy
with `-c 7`; confirms only the 20 Piet colours appear; runs seven
hand-painted programs, built from its own copy of the Piet op table, that
pin the interpreter to the spec (push, out_num, in_char, out_char, sub
operand order, dup, mul, not, div, white, turning at a wall); and runs four
sabotaged copies of the interpreter that must fail either the round trip
or a spec program.

## Limits

- Text only round-trips through characters 1 to 127; NUL is not tested.
- The painting is a strip, not a picture. It is honest Piet, not pretty Piet.
- The interpreter has only been checked against these tests, not against
  another Piet interpreter.

MIT License. Copyright (c) goblincouncil.
