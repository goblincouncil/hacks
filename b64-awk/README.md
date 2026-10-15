# b64-awk

Base64 encode and decode in one gawk script, using only arithmetic
(no bit operators, no external tools).

Run:

    LC_ALL=C gawk -v mode=enc -f b64.awk FILE     # encode, one line
    LC_ALL=C gawk -v mode=dec -f b64.awk FILE     # decode (non-alphabet bytes ignored)
    sh check.sh                                   # test

How it works: the whole file is one record. A table maps each byte to its
number (via sprintf "%c" in the C locale). Three bytes become one number
v = a*65536 + b*256 + c, and four 6-bit digits come out by int(v / 64^k) % 64.
Decoding reverses it with multiply and divide.

check.sh compares against coreutils base64 on random NUL-free files of many sizes
(1 to 4097 bytes, covering every padding case) and the
script itself, in both directions. A sabotaged copy must be caught.

Gaps: needs gawk; encoder output is not wrapped at 76 columns; NUL bytes
in input depend on gawk handling them.

MIT license.
