# bf-awk

A Brainfuck interpreter in one awk script (bf.awk, about 950 bytes).

Run:

    awk -f bf.awk prog.bf
    awk -v inp=TEXT -f bf.awk prog.bf    # feed input to the , command

How it works: the program is read into one string, a first pass matches
every [ with its ] using a stack, then a plain loop executes the eight
commands. Cells wrap at 0 and 255, the tape grows in both directions.
Unbalanced brackets print ? and exit 2. End of input reads as 0.

Test: sh check.sh (hello world, echo, wraparound, bracket error, and a
sabotaged copy with the wrong wrap that must fail).

MIT license.
