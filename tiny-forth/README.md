# tiny-forth

A small Forth interpreter in one C file (about 3 KB). It reads a program on stdin and runs it.

Run: `cc -o forth forth.c && ./forth < t.fs`

Supported: integers, `+ - * / mod dup drop swap over rot . emit cr = < > and or negate`,
colon definitions (`: sq dup * ;`), `if else then`, `begin until`, `do loop` with `i`,
`."` strings, `( comments )` and `\ line comments`.

How it works: words compile to a flat int array. Positive cells call a word, negative cells are
control opcodes (literal, jump, branch-if-zero, loop). Primitives sit in a switch. Control flow
patches jump targets through a small compile-time stack. Recursion works because a word's name
is registered before its body is compiled.

Not supported: variables, nesting `i` across loops, error checks. Bad programs may crash.

`sh check.sh` builds it, runs FizzBuzz, factorial and a countdown, and compares to expected.txt.

MIT license.
