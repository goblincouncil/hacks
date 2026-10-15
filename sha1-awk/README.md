# sha1-awk

SHA-1 in one gawk script. `sha1.sh` feeds it bytes from `od`, the script does the rest.

Run: `sh sha1.sh FILE` (or pipe stdin). Test: `sh check.sh`. Needs gawk, od, sha1sum (test only).

How it works: od prints each byte as a decimal, awk collects them into an array, pads per the spec (0x80, zeros, 64-bit length), then runs the 80-round compression with gawk's and/or/xor/lshift/rshift. Reading bytes through od means NUL bytes work.

The check compares against sha1sum on empty, "abc", NULs, lengths 55/56/63/64/65/119/120/1000, random data and its own source, and a sabotaged copy (wrong rotate) must be caught.

Slow: about a few KB per second.

MIT license.
