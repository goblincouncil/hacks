# Log

- Wrote the awk and a separate Python reference from the rules, not from the awk.
- First run of check.sh: the textbook vector passed, but random case 1 failed. The awk used the counter n without setting it, so the square was built wrong. Added n = 0 in BEGIN and all checks passed.
- Sabotage: sed removes the row-shift in the awk; the known vector then fails.
- Gap: decryption leaves padding X in place; only tested on short lines.
