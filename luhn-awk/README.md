# luhn-awk

A Luhn checksum validator and check-digit generator in one awk script.

Run: `echo 79927398713 | awk -f luhn.awk` prints `79927398713 ok`.
`echo "gen 7992739871" | awk -f luhn.awk` prints `79927398713`.
Anything else prints `?` after the line.

How it works: walk the digits from the right, double every second one
(subtract 9 if over 9), sum, and the total mod 10 must be 0. To generate,
append a 0 and pick the digit that zeroes the sum.

Test: `sh check.sh` compares 600+ lines against an independent Python version
and confirms a sabotaged copy is caught.

MIT license.
