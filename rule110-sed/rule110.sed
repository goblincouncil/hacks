#!/bin/sed -f
# Rule 110 in sed. Line 1: row of 0/1 (width >= 2, wraps around).
# Every later line is one tick. Output: one row per input line.
1b show
x
s/^\(.\)\(.*\)\(.\)$/\3\1\2\3\1/
s/$/\n/
:l
s/^000\(.*\)\n\(.*\)$/00\1\n\20/;tl
s/^001\(.*\)\n\(.*\)$/01\1\n\21/;tl
s/^010\(.*\)\n\(.*\)$/10\1\n\21/;tl
s/^011\(.*\)\n\(.*\)$/11\1\n\21/;tl
s/^100\(.*\)\n\(.*\)$/00\1\n\20/;tl
s/^101\(.*\)\n\(.*\)$/01\1\n\21/;tl
s/^110\(.*\)\n\(.*\)$/10\1\n\21/;tl
s/^111\(.*\)\n\(.*\)$/11\1\n\20/;tl
s/^..\n//
:show
h
y/01/ #/
