# ant-sixel

Langton's ant in one awk script, printed as a DEC sixel image. In a terminal
that speaks sixel (xterm -ti vt340, mlterm, foot, WezTerm, recent Konsole)
you `cat` the output and the picture appears right in the scrollback.

## Run it

    awk -f ant.awk > ant.six                     # 11000 steps, 4 px per cell
    cat ant.six
    awk -v steps=2000 -v scale=2 -f ant.awk      # fewer steps, smaller

No sixel terminal? `convert ant.six ant.png` (ImageMagick) turns it into a PNG.

Test it with `sh hack/check.sh` (needs awk and python3; ImageMagick is used as
a second opinion when present).

## What you see

The ant sits on a grid of white cells. On a white cell it turns right, on a
black cell it turns left; either way it flips the cell and steps forward. For
about ten thousand steps it makes a mess, then it suddenly starts building a
diagonal "highway" that repeats every 104 steps, forever. At 11000 steps the
highway is sticking out of the mess. Black cells are dark ink on warm paper,
and the ant itself is the red square.

## How it works

- The grid is an awk associative array keyed by `"x,y"`; only black cells are
  stored, so the board has no edges. The script remembers the bounding box of
  every square the ant visits and adds one cell of margin.
- Sixel draws in horizontal bands six pixels tall. Each character from `?` to
  `~` is 63 plus a 6-bit mask saying which of the six pixels in that column get
  the current colour. For every band the script writes one pass per colour,
  `$` returns to the left edge, and `-` moves down to the next band.
- `!<count><char>` repeats a character, so the long runs of paper and the
  regular highway cost almost nothing: 11000 steps at scale 2 is a 2.6 KB file.

## How it is checked

`check.sh` runs the awk script for several step counts and scales, then
`ref.py` decodes each sixel with its own small decoder and compares every
pixel against a separately written Python ant (complex numbers instead of
direction tables). ImageMagick decodes one picture too, as an independent
reader. Four sabotaged copies of `ant.awk` (swapped turns, upside-down sixel
bits, an off-by-one repeat count, a missing ant) must all be caught.

MIT License. Copyright (c) 2026 goblincouncil.
