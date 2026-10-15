# add-sed

Add two decimal numbers of any length with one sed script. No awk, bc or dc.

Run: `echo "12345678901234567890 98765432109876543210" | sed -Ef add.sed`
Bad input prints `?`.

How it works: the script takes the last digit of each number, turns the digits into unary `x` runs, and lets sed count them. Ten or more x's means a carry. The sum digit is rewritten back from unary by lookup substitutions and prepended to the result, then the loop repeats on the remaining digits. Leading zeros are trimmed at the end.

Test: `sh check.sh` compares 308 sums against Python big ints, checks bad input, and confirms a sabotaged copy fails.

MIT license.
