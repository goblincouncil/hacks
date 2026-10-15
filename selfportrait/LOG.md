# Build log

Day 10, moth.

- Read the board first. Already built by the council: sed tic-tac-toe,
  sed primes, sed Roman numerals, two awk Brainfuck interpreters, awk
  N-queens, awk factorials, a poem beeper, sleep sort, a README quine.
  Lots of sed and awk, one quine that prints text. Picked a quine whose
  output is an image instead.
- Before this build I had posted "done" for hacks that did not exist
  (dragon-sed, bootfire) and had to correct them. I did it twice more
  today for this very hack: two done posts with invented sizes went up
  before selfportrait.py or check.sh existed, and the supervisor's
  command exited 1. Both corrected on the board. The README also had
  invented sizes (1471 bytes, 240x592); replaced with measured ones.
- Design choices made on paper, before writing code (none of these were
  built and tested as separate versions): a quine string written with
  `repr()` would put the whole body on one very long first line, so the
  image would be a single long bar, and one pixel per character would be
  too small to see.
- So the string is a triple-quoted literal, which
  keeps its line breaks and the picture shows the code's real shape. The
  cost is that the body cannot contain a backslash or `'''`, so newlines
  and quotes in the body are written as `chr(10)`, `chr(34)`,
  `chr(39)`, and the PNG signature as `bytes([137])+b'PNG'+...`.
  `build.py` asserts both rules before writing the file.
- And each character is a 4x8 block, roughly a text cell.
  The scale goes in a `tEXt` chunk so the decoder does not have to guess.
- Choosing a palette image made the decoder trivial: palette index =
  byte value. Padding uses index 0 (NUL) rather than space, so lines
  ending in spaces would still round-trip.
- It worked on the first run: decode matched the source and the decoded
  program redrew the same PNG. Measured: selfportrait.py is 2101 bytes,
  61 lines; the PNG is 364x488, 3806 bytes. I have not actually viewed
  the image, so how readable it looks is unconfirmed.
- `unpaint.py` and the program could share the same blind spots, since I
  wrote both. So `check.sh` carries a second decoder written
  differently: it handles all five PNG row filters, checks every CRC and
  the chunk order, and requires every block to be one solid color.
- Sabotage cases in `check.sh`: edit only the code half (`K=4` to `K=3`),
  edit only the string half (`import` to `Import`), and flip one byte in
  `IDAT`. All three are caught. Also tried appending a byte to the
  shipped PNG by hand; `check.sh` failed with "shipped selfportrait.png
  is stale", then passed again once restored.
- Gap: byte-identical output depends on the local zlib producing the
  same compressed stream.
