# bigfact

Arbitrary-precision factorials in one awk script.

Run: `echo 100 | awk -f bigfact.awk`. One integer per line in, n! out; anything else prints `?`.

How it works: awk numbers are doubles, so the big number lives in an array of base-10000 limbs. Each step multiplies every limb by i and carries. Output pads inner limbs to four digits.

Test: `sh check.sh` compares 0..500 against Python's math.factorial and confirms a sabotaged copy fails.

MIT license.
