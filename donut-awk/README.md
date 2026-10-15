# donut-awk

The spinning ASCII donut, as one awk script. A torus turns on two axes in
your terminal, shaded with the twelve characters `.,-~:;=!*#$@`.

The maths is the well-known `donut.c` by Andy Sloane, ported to awk.

## Running it

    awk -f donut.awk                        # animate forever, needs 80x22
    awk -v play=1 -v frames=200 -f donut.awk   # animate 200 frames
    awk -v frames=3 -f donut.awk            # print 3 plain frames, each ended by --

Plain mode has no escape codes and no trailing spaces, so frames can be
diffed and tested.

## How it works

The surface of the torus is walked with two angles: 90 steps around the
ring and 314 around the tube. Each point is rotated by two spin angles that
grow every frame, projected onto an 80x22 grid, and given a brightness from
the dot product of its surface normal with a fixed light.

Awk has no real 2D arrays, so the screen is two flat arrays indexed by
`x + 80*y`: one holds the character, the other a z-buffer. The z-buffer
stores 1/depth rather than depth, so a cell that was never drawn (an empty
awk value, which counts as 0) always loses to a real point.

## Checking it

    sh check.sh

The check compares 60 frames byte for byte against `ref.py`, a separate
Python version of the same maths, checks the frame shape and that frame 0
has a hole in the middle, checks the escape codes of animation mode, and
makes four sabotaged copies of the script that must all be caught.

It needs gawk (or another awk with `sin`, `cos`, `fflush`) and python3.

MIT license.
