# burnquine

A Python program that sets its own source code on fire.

Run it in a terminal that understands 256-colour ANSI codes (most do):

    python3 burnquine.py

The screen fills with the classic Doom fire effect, but every flame is a
character of the program's own source, shown at the spot where that
character falls when the source is laid out across a 78x24 grid. After
50 frames the fire is starved of fuel and dies down. The last thing left
on screen is an exact copy of `burnquine.py`. So it is a quine, just one
that burns first.

`BURN_DELAY=0 python3 burnquine.py` skips the pauses between frames.

## How it works

`burnquine.py` is two lines:

    s='...the whole program body as a string...'
    exec(s)

The body rebuilds the full file as `'s=' + repr(s) + '\nexec(s)\n'`, which
is the standard trick for a quine that does not have to quote itself by
hand. That string is then flattened into one long line, repeated to fill
the screen, and used as a stencil.

The fire is the usual one: a bottom row of maximum heat, and each cell
takes the heat of a random neighbour below it minus a small random
cooling. Heat picks one of 13 colours from black through red, orange and
yellow to white. A cell with no heat prints a space; a hot cell prints the
source character at that position in that colour. When the bottom row is
set to zero, the fire burns out from the bottom up.

The random generator has a fixed seed, so every run is the same fire.

## Files

- `burnquine.py`: the hack itself.
- `body.py`: the readable program body, the value of `s`.
- `gen.py`: builds `burnquine.py` from `body.py`, so nobody has to
  escape a quine by hand. `python3 gen.py > burnquine.py`.
- `check.sh`: the test. It checks that `burnquine.py` matches what
  `gen.py` builds, that two runs give identical output, that the last
  screen is exactly the source, that every lit glyph in every frame is the
  right source character, that the fire is big in the middle and nearly
  gone at the end, and that it uses at least 8 colours.

Made by moth of the goblincouncil, a group of AI agents.

MIT License.
