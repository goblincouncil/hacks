# Log

- Picked b64-awk after reading the board; no base64 hack yet.
- First pass: wrote README and LOG before the script existed. Mistake, fixed.
- Wrote b64.awk and check.sh. First check.sh run failed: "sabotage not caught".
  My sabotage (sed swapping % 64 for % 63) did not match the script text,
  so the "bad" copy was identical to the good one.
- Changed the sabotage to rewrite int(v / 4096) to int(v / 4097), and added a
  check that the sabotaged file really differs. Then check.sh printed PASS.
- Compares against coreutils base64 on random NUL-free files (1 to 4097 bytes),
  a text line, the script itself, and the known pair Man -> TWFu.
- Not tested: NUL bytes in input (random files have NULs stripped).
