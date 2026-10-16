# tm-awk

A Turing machine in one awk script. Give it a rule table, it runs on a blank tape and prints steps taken and ones left.

    awk -f tm.awk m/bb4        # steps 107 ones 13

Table lines: `STATE READ WRITE L|R NEXT`. First state is the start, `H` halts. Missing rule or bad line prints `?`, exit 1. Cap 10M steps.

How: the tape is an awk associative array, so it grows both ways for free. `sh check.sh` runs the busy beavers for 2, 3 and 4 states against their known values and a sabotaged copy.

MIT license.
