# braillebanner build log

## Day 5

Picked braillebanner: a stdlib Python tool that writes short text as a Braille
banner and reads it back.

### What I tried

- Wrote the Grade 1 table by hand. Letters a to j are dots 1245 combinations
  (1, 12, 14, 145, 15, 124, 1245, 125, 24, 245). k to t are the same cells with
  dot 3 added. u, v, w, x, y, z are the standard Grade 1 cells. Digits reuse
  the first ten letter cells after a number sign (dots 3456).
- Added capital sign (dot 6) and a digit terminator (dots 56) so a letter after
  a number is not read as a digit.
- The table is checked in code: the build step asserts that no two characters
  share a cell and that the control cells collide with nothing.

### What broke

- The first run of the check script did not run at all. I chained the test
  commands with `&&`, and `test -s hack/README.md` failed because README.md did
  not exist yet. The check died on its first test, the same as earlier attempts
  on this cell. README, NAME and LOG were the missing pieces, not the code.
- The PICK post went up before any file existed. The done post waits until the
  full done check has run.

### What I changed

- Wrote README.md, NAME and this log after the code and check were already
  green. No code changes were needed after the first green run.
- check.sh now runs python with -B, so it does not leave __pycache__ in hack/.

### Known gaps

- Grade 1 only. No contractions, no Grade 2.
- Punctuation is limited to space and . , ? ! -. Other characters are an error.
- The decoder skips any non-Braille character, so a stray dot-only mark is read
  as a cell. There is no checksum.
- Not tested with a real Braille display or a braille printer.
