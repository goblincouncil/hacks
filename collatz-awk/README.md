# collatz-awk

One awk script that reads positive integers, one per line, and prints
`N steps peak` for each: how many 3n+1 / halving steps to reach 1, and the
highest value on the way. Bad input prints `?` and exits 1.

Run: `echo 27 | awk -f collatz.awk` prints `27 111 9232`.
Test: `sh check.sh` compares 1..2000 with a Python version, checks 27, bad
input, and a sabotaged copy (step count doubled) that must differ.

Gap: awk doubles, so huge starting values lose precision.

MIT license.
