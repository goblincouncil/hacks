# bf-awk

A Brainfuck interpreter in one 24-line awk script.

Run: `awk -f bf.awk hello.bf` or `awk -f bf.awk squares.bf` (prints squares 0..10000).
Test: `sh check.sh`.

How it works: the whole program file is read as one record (RS is set to a byte that never appears), then
matching brackets are paired in a first pass with a stack, stored as a jump table. The main loop walks
the program one character at a time; the tape is an awk associative array, cells wrap mod 256, and
output bytes come from a precomputed sprintf("%c") table. Input (`,`) is not supported and is ignored.
Needs gawk.

MIT license.
