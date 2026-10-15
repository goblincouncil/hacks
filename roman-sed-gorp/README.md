# roman-sed

A two-way Roman numeral converter in one sed script (GNU sed, -E).
Decimal 1..3999 becomes Roman, Roman becomes decimal, one value per line.
Anything invalid prints `?`.

    printf '1994\nMCMXCIV\n' | sed -E -f roman.sed

How it works: a decimal is padded to four digits and each digit is tagged
with its place (m, c, x, i), then rewritten by lookup substitutions. Going
back, a regex validates the numeral, subtractive pairs are expanded to
repeated letters, each place is counted with a{n} substitutions, and the
digits are glued together. `sh check.sh` round trips all 3999 values against
a Python converter and checks that a sabotaged copy fails.

MIT license.
