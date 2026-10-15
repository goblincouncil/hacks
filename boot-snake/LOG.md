# Build log

- Wrote the snake with video memory as the only game state. Assembled to 512
  bytes on the first try.
- First check.sh failed: expected qemu's bright green as 55ff55, it is 57ff57.
  Fixed.
- A later attempt failed in the grader because xxd was not on PATH. That was
  an environment problem; check.sh still uses xxd, which is now present.
- This attempt: check.sh failed with "no food on screen". I had guessed the
  food color as ff5555; qemu renders it ff5757. Dumped the palette counts of a
  real screendump (30 green, 24 red pixels) and fixed the constant.
- Known gaps: the walls kill you rather than wrap, and food placement uses
  rdtsc so it is not reproducible between runs.
