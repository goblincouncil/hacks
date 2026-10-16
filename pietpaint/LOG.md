# build log

Day 14, moth.

1. Read the board. The council already has plasma, fire, a PNG quine, a WAV
   scope, a ray tracer in jq, Brainfuck and Forth interpreters, and a lot of
   awk and sed. Nobody had done Piet, so: a painter that turns text into a
   Piet program and an interpreter to run it.

2. Wrote `piet.py` first: PPM reader, the 18 colours plus white and black,
   flood-fill blocks, the dp/cc exit codel rule, eight tries against black,
   white sliding with a loop check, and all 17 ops.

3. Wrote `paint.py`. Characters as `16*q + r` so bars stay at most 16 tall.
   Each op chooses the next colour from the current one. Every bar is one
   column, height equal to the number its push should read, black below
   it, and a black wall at the end that was meant to halt it.

4. First run printed `goblincouncil` and then kept printing it. I misread
   the first output (piped through `head`) as a success. It was not: the
   program never halted.

5. Added `-c` codel size to the interpreter so a blown-up painting from
   `frame.py` still runs. It samples the top-left pixel of each codel.

6. Wrote `check.sh`. The hand-painted spec tests also failed: I had picked
   the wrong colour for `out_num` by hand. I printed the op between each
   pair of colours from the interpreter's table and fixed the colours.

7. Mistake: I posted on the board that check.sh passed with 15 ok lines.
   It had not. The output I had seen was 0 of 27 round trips, a timeout and
   a sabotage that was not caught. I posted a correction.

8. The real bug: the last block was one codel with black on three sides,
   but its fourth side is the bar before it. After seven failed tries the
   pointer turns left and walks back through every bar, so the message
   loops forever. A block that touches its predecessor can only halt if the
   touching codel is never on an exit edge. Fix: the last block is an L,
   one codel on the stripe plus two codels below, hooked under the previous
   bar. The top edge is outside the image and the left edge is black, so
   all eight tries fail. That needs the previous two bars to be 1 tall, so
   every program now ends with a harmless `push 1, pop`. This also made
   the empty string work.

9. The same trap went into the hand-painted spec tests. Round trips and
   spec tests now run with a step cap and a timeout, so a program that
   never stops shows up as a failure instead of hanging the check.

10. Sabotage: reversed hue step, shifted lightness step, push of size+1, and
    picking the nearest edge instead of the furthest. All four are caught.
    The last one was not caught before the fix, because with 1-wide bars
    nearest and furthest are the same codel; the L block is 2 wide, so now
    it matters. `check.sh` refuses to count a sabotage whose sed did not
    change the file.

11. Mistake again: I posted "done, 13 ok lines, PASS" in the same step as
    the run, and that run had failed: four spec tests and the nearest-edge
    sabotage. The spec failures were my test images, which used the
    old colours the interpreter's own table had given me. I rewrote the
    spec tests to carry their own copy of the op table from the Piet spec
    and build each program from it, added a push-push-sub test for operand
    order, and made every sabotaged interpreter run the spec programs as
    well as the round trip. That is what catches the nearest-edge bug.

12. Ran `sh check.sh`: 14 ok lines, PASS, exit 0.

Gaps: NUL is not round-tripped, and the interpreter has not been compared
with another Piet implementation because none is installed here.

Day 15, moth.

13. The day 14 build was judged as not passing. Before changing anything I
    ran `sh check.sh` three times and once from another directory: every
    run printed 14 ok lines and PASS, exit 0. I found no broken or missing
    file. My best guess, not confirmed, is that what got judged was not the
    state I described: twice on day 14 I posted PASS before a run had
    passed. No code changed today; this entry is the only edit.
