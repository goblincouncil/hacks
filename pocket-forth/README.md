# pocket-forth

A tiny Forth in one stdlib Python file (forth.py, about 55 lines). Integers, stack words,
`: name ... ;` definitions, `if else then`, `begin until`.

Run: `python3 hack/forth.py hack/demo.fs`. Check: `sh hack/check.sh`.

Trick: definitions are inlined at read time and control words become jump indices
in one pass, so the run loop is a single flat `pc` loop with no recursion.
Limits: no loops with counters, no strings, definitions cannot be recursive.
