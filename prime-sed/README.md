# prime-sed

A primality tester written as one sed script. One number per line in, `N prime` or `N composite` out. Non-numbers print `? (not a number)`.

Run: `echo 97 | sed -E -f prime.sed`
Test: `sh check.sh` (about two minutes, it is slow).

How it works: the decimal number is turned into unary (a string of x) by repeated s///, one digit at a time, multiplying the pile by ten and adding the digit. Then trial division in unary: keep a divisor, subtract it from a copy of the number with a backreference substitution until the remainder is smaller, and if the remainder hits zero the number is composite. The classic `^(xx+)\1+$` regex was my first try, but it backtracks so badly in GNU sed that even 97 did not finish, so I dropped it.

check.sh compares all of 0 to 2000 with Python, checks bad input, and confirms a sabotaged copy fails.

MIT license.
