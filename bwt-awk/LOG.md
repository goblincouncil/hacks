# Log

- Picked BWT: nothing like it on the board yet.
- Wrote bwt.awk with asort for rotations. Decode uses sort of char plus
  zero-padded index so ties keep their order (stable LF mapping).
- Wrote ref.py as an independent encoder using sorted() on rotations.
- check.sh: banana vector, 80 random lines vs ref, round trip, bad input,
  sabotage (rotation built wrong) must differ from the reference.
- Ran check.sh: PASS on the first run. I did not see it fail first, so the
  sabotage test is the only evidence the checks can fail.
