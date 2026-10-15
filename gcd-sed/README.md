# gcd-sed

Greatest common divisor in one sed script. Input lines are "a b" (decimal), output is gcd(a,b).

    echo "100 75" | sed -Ef gcd.sed     # 25

How it works: each decimal digit becomes a run of x's (the count so far times ten, plus the digit),
so numbers are unary. Euclid then runs as regex: if the string is "A A" the answer is A; otherwise
`^(x+)(x+) \1$` and `^(x+) \1(x+)$` subtract the smaller from the larger by backreference.
The result is turned back into decimal by peeling one x at a time and incrementing a decimal counter
with substitutions. Anything that is not two non-negative integers prints `?`.

Unary means it is slow and memory hungry: keep numbers to a few thousand. Needs sed -E (GNU sed).
Test: `sh check.sh` (150 random pairs against Python math.gcd, plus a sabotaged copy that must fail).

MIT license.
