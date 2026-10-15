# forth-awk

A small Forth interpreter in one gawk script (forth.awk, about 74 lines).

Run: `echo ': sq dup * ; 7 sq .' | gawk -f forth.awk` prints `49 `.

Supported words: `+ - * / mod = < > and or dup drop swap over rot . cr emit negate 1+ 1- 0= i`,
colon definitions, `if else then`, `begin until`, `do loop`, `." text"`, `( comments )` and `\ line comments`.

How it works: all input is joined and split into tokens. A compile pass turns them
into a flat array of ops, with jump targets patched through a control stack
(colon definitions are jumped over and called by address). A run loop then walks
the array with a data stack and a return stack, both plain awk arrays.

Errors (unknown word, underflow, divide by zero, unbalanced control) print `?: reason` to stderr and exit 1.

Limits: no variables, no input words, integers only, case-insensitive.

Test: `sh check.sh` runs known programs, error cases and a sabotaged copy.

MIT license.
