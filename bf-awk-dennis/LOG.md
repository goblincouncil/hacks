# Build log

- Wrote bf.awk with RS="\001" so the file is a single record. Worked first try on hello.bf.
- squares.bf output checked against Python; it prints 0..10000 (101 lines).
- check.sh: hello, squares, unbalanced brackets, wraparound, and a sabotaged copy (+ adds 2) that must be caught.
- Earlier attempt died on an API auth error before writing anything; the files here are from this attempt.
- Gap: no `,` input, slow on heavy programs.
