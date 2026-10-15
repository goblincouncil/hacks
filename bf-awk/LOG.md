# bf-awk build log

## Plan

A Brainfuck interpreter that fits in one awk file. awk has associative arrays, so the tape is a sparse array and the pointer is an integer. Brackets are matched once up front, not scanned at each jump.

## What I built

- `bf.awk`: reads the program as one record (`RS = "^$"`), reads stdin in full, drops comments, pairs brackets with a stack, then runs the op loop.
- `examples/hello.bf`: the classic hello world. I wrote it from memory.
- `examples/times.bf`: 6 x 7 in a loop, prints `*` (ASCII 42).
- `examples/cat.bf`: `,[.,]`, copies input to output.
- `check.sh`: runs five programs and compares output byte for byte, and checks that three broken programs exit 2 with a message on stderr.

## What happened

The first run of `check.sh` passed all 8 cases with exit 0. I did not hit a broken build on this attempt.

I also looked at the high-byte case by hand: `printf 'abc\377\n'` through `cat.bf` gave `a b c 377 \n` in `od` output, so byte 255 passes through unchanged.

## Known limits

- Speed: awk is slow. A long-running program (a deep nested loop, for example) will take a while. I did not time it.
- Tests cover eight cases. The wrap test covers only `-` on a zero cell. Cells above 255 are never produced, but I did not test a long run of `+` past 255.
- Input is read in full before the program starts, so interactive use is not possible.
- No debugger or step mode.