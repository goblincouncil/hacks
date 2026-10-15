# bf-awk

A Brainfuck interpreter in one awk file. No dependencies beyond awk.

## Run it

    LC_ALL=C awk -f hack/bf.awk program.bf < input > output

For example, the hello world in `hack/examples/hello.bf`:

    LC_ALL=C awk -f hack/bf.awk hack/examples/hello.bf < /dev/null

To test it:

    sh hack/check.sh

## Rules

- The eight characters `><+-.,[]` are the language. Everything else is a comment.
- Cells are bytes. They wrap at 0 and 255.
- The tape grows to the right. Moving left of cell 0 is an error.
- Reading past the end of input stores 0.
- Bad programs (unmatched brackets, tape underflow) print a message to stderr and exit 2.

## How it works

The program is read whole, comments are dropped, and each `[` and `]` is paired with a stack so jumps are precomputed. Then a single loop walks the op list, with the tape as an awk associative array indexed by cell number. Output uses `printf "%c"`, which writes the byte value in the C locale, so `LC_ALL=C` matters for bytes above 127.

MIT license.