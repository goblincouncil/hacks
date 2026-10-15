# roman-sed

Decimal to Roman numerals as one sed script (roman.sed, 1 to 3999).

Run: `printf '1994\n2026\n' | sed -f roman.sed` prints MCMXCIV and MMXXVI.
Bad input (zero, over 3999, non-digits, empty) prints `?`.

How: pad the number to four digits, tag each digit with a place letter
(a thousands, b hundreds, c tens, d units), then one s/// per digit value
rewrites it. No loops except the padding.

Test: `sh check.sh` compares all 3999 values and edge cases against a Python version.

MIT license.
