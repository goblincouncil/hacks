# rotogif

A rotozoomer, the old demoscene effect where a patterned floor spins and
zooms under you, written as one standard-library Python file that writes an
animated GIF by hand. No imaging library: the GIF header, palette, frames
and LZW compression are all built byte by byte in `rotogif.py`.

The odd part: the GIF carries its own source code. GIF89a has a comment
block that image viewers ignore, and rotogif puts the whole `rotogif.py`
in it. Pull the source out of the picture, run it, and you get the same
GIF back, byte for byte.

## Run it

    python3 rotogif.py                       # writes rotogif.gif
    python3 rotogif.py out.gif               # or name the file
    python3 rotogif.py --extract out.gif     # print the hidden source
    python3 rotogif.py --extract out.gif copy.py

The result is 128x128, 32 frames at 40 ms each, looping forever, about
340 KB. Rendering takes well under a second.

    sh check.sh                              # the test, exits 0 on success

## How it works

- Each frame samples an XOR texture `(u ^ v)` through a rotation, a zoom
  and a pan, then shifts the colour index. The palette is three sine waves
  120 degrees apart, so the colours cycle smoothly.
- The loop is seamless because every moving part completes whole cycles
  in 32 frames: one full turn, one zoom breath, a pan that traces a figure
  eight, and a colour shift of 256 steps (8 per frame), which wraps to 0.
  The frame index is wrapped before any trig, because `cos(2*pi)` is not
  exactly 1 in floating point and the `floor` calls would turn that tiny
  error into thousands of wrong pixels.
- The encoder is GIF-flavoured LZW: codes start at 9 bits, widen as the
  dictionary grows, are packed least significant bit first, and a clear
  code resets the table when it hits 4096 entries.
- `--extract` walks the GIF blocks, finds the comment extension (0x21 0xFE)
  and joins its 255-byte sub-blocks back into the file.

It is not a true quine: the script reads its own file to embed it.

## The test

`check.sh` runs `verify.py`, which shares no GIF code with `rotogif.py`.
It has its own block parser and LZW decoder, decodes all 32 frames,
compares them with the renderer and with ImageMagick's decoding, checks the
loop block, the frame delays, that the loop closes, that the comment is the
script byte for byte, and that the source taken out of the GIF rebuilds the
identical GIF. Then it breaks five copies of the script on purpose and
requires `verify.py` to reject each one.

Needs `python3`; the ImageMagick cross-check needs `convert` or `magick`.

MIT License. Copyright (c) 2026 goblincouncil.
