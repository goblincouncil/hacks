# barcode-awk

Text in, a barcode out, from one awk script.

`barcode.awk` reads one line of printable ASCII and prints a Code 128 barcode
(code set B) as a plain PBM image: the `P1` format, which is just a header and
then ones and zeros, so the picture is plain text too. Any image viewer that
knows PBM can open it.

## Run it

    echo goblincouncil | awk -f barcode.awk > goblin.pbm
    python3 decode.py goblin.pbm      # prints: goblincouncil
    magick goblin.pbm goblin.png      # if your viewer wants PNG

`goblincouncil.png` in this folder is that barcode, 396x80 pixels.

Options, passed with `-v`:

- `scale=N` module width in pixels (default 2)
- `h=N` bar height in pixels (default 60)

Only the first input line is used. An empty line, no input, or any character
outside ASCII 32 to 126 (tabs, accents, emoji) is refused with exit status 1.

## How it works

A Code 128 symbol is 11 modules wide: three bars and three spaces, each 1 to 4
modules. The script keeps all 107 symbols as one string of six-digit width
codes (`212222` is symbol 0: bar 2, space 2, bar 2, ...). To encode:

1. Start with symbol 104, "Start B".
2. Each character becomes its ASCII code minus 32.
3. Add a checksum: the start value plus each symbol times its position, mod 103.
4. End with symbol 106, "Stop", which is 13 modules wide.

Then it expands the widths into a row of ones and zeros, pads ten blank modules
on each side (the quiet zone a scanner needs), widens each module by `scale`,
and repeats that row `h` times between blank margins.

The one trick: the PBM is text, so the whole pipeline from letters to bars is
string pasting. awk never touches a pixel buffer.

## Check

    sh check.sh

It needs awk, sed, cmp and python3 (stdlib only). Two helpers sit beside the
script:

- `ref.py`, a separate Python encoder that holds the table as 11-module bit
  strings rather than width codes.
- `decode.py`, a reader that takes the middle pixel row of a PBM, measures the
  bar and space runs, and turns them back into text, verifying start, checksum,
  stop and quiet zone.

check.sh encodes 49 strings (fixed ones covering all 95 printable characters,
plus random ones) at three sizes. Each must decode back to the same text and
match `ref.py` byte for byte. A barcode with one module flipped must be
refused by the decoder, bad input must be refused by the encoder, and five
sabotaged copies of the script (wrong checksum weight, wrong modulus, wrong
start code, two table entries swapped, no quiet zone) must each be caught.

Limits: code set B only, so no control characters and no compact digit mode
(set C). Never read by a real scanner or by zbar, which was not available
where this was built. The decoder is mine, so a mistake shared by my encoder,
my reference and my decoder would slip through; the table was checked run by
run between two different forms, which makes that less likely, not impossible.

MIT license.
