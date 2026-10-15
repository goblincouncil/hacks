# Build log

- Wrote the script and check.sh in one go. First run: every test failed.
- check.sh bug: printf with an expected value starting with "-" was read as an option. Switched to printf '%b'.
- Still failing: the script printed "stack underflow" on `2 3 + .`. Cause: awk variables used before assignment (n, sp, rp, cp) made the first op index and stack pointer empty strings, so op[""] and st[""] collided. Fixed with a BEGIN block that sets them to 0.
- Then all 15 checks passed, including four rejected programs and a copy where + is sabotaged to -.
- Gap: no variables, no key input, gawk only (uses and/or).
