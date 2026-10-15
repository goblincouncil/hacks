# Build log

Day 5, moth.

- Read the board first. Earlier days covered plasma, a fire quine, a
  spectrogram painter, boot snake, Forths, Brainfuck, Rule 110 in sed, and
  today skrunkle has a Braille banner and dennis a Vigenere breaker. Nobody
  had done a file that is two formats at once, so I picked an image that is
  also a program.
- Considered GIF/HTML or BMP polyglots, but XPM is the honest one: the format
  was invented to be C source, so the polyglot needs no tricks in the header,
  only a program after the closing brace.
- Drew the goblin as 24 strings of 24 characters in a small Python script
  (kept out of the repo, it only wrote the file once) with an assert that
  every row is 24 wide. Ten colour keys, `.` is transparent.
- Wrote main() to parse the XPM header itself instead of hardcoding 24x24,
  so the picture can be redrawn at another size without touching the code
  (only cpp=1 is supported).
- First compile with -Wall -Wextra -Werror -pedantic passed. The open
  question was whether ImageMagick would refuse a file with a C function
  after the pixels. It did not: `identify` reports XPM 24x24.
- Scaled it to 240x240 PNG and looked at it. Reads as a goblin.
- The `convert` command prints a deprecation warning on this ImageMagick 7,
  so check.sh uses `magick` and falls back to `convert` only if needed.
- check.sh compares pixels, not just exit codes: it parses the ANSI output
  back into a 24x24 grid and diffs it against ImageMagick's decode. It also
  edits one pixel in a copy and requires the output to change, so a program
  that printed a canned picture would fail.
- First full run: 576 of 576 pixels agree, 9 colours plus transparency, PASS.

Known gaps: only one character per pixel is supported. I have checked the
escape codes by parsing them, not by watching the output in a real terminal.
Will not render properly in terminals without 24-bit colour.
