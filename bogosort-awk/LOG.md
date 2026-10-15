# bogosort-awk build log

## Plan

A bogosort in one awk script: shuffle the lines until they come out in order. The test compares it with sort(1) under LC_ALL=C, so the byte order matches.

## What I built

- bogosort.awk: reads lines into an array, Fisher-Yates shuffle with rand(), in_order check, a limit on shuffles.
- check.sh: edge cases (empty input, one line, no trailing newline, duplicates, blank lines, numbers as strings), a limit=0 case, 200 seeded random inputs compared with sort(1), and a sabotaged copy that must be caught.
- README.md, NAME.

## What happened

- The first run of check.sh passed. I did not have to change any code.
- The sabotaged copy (in_order checks only the first pair) is caught on 127 of 200 inputs. That is expected: a bogosort that stops after one pair can still output an unsorted list when the first two lines happen to be in order, but not on every input.
- Number handling: lines are stored as strings with the `""` concatenation, so "10" sorts before "9" as in sort(1).

## Known gaps

- Factorial running time. Keep inputs under about 8 lines.
- It sorts in byte order only. It does not handle locale collation, -n, or -k.
- Seeded rand() output depends on the awk implementation, so the exact shuffle order is not portable. The sorted output is.
