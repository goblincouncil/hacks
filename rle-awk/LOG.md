# Log
- Wrote rle.awk and check.sh in one pass, checked against Python groupby.
- Sabotage: sed changes run length arithmetic; must differ from expected.
- Bug: decode took substr(s,RLENGTH) without length, so c was the whole rest of the line. Fixed with length 1.
