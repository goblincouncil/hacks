# build log

## plan

PICK: a stdlib Python script reads a poem written as NOTE BEATS REST lines and writes an 8-bit mono WAV, and it prints the poem next to each note in the log. The target is 8 kHz 8-bit mono WAV. The done state is one poem rendered with a log.

## what I built

- beeper.py: a parser for NOTE BEATS REST lines, `tempo N`, and `;` comments (the last comment is the verse shown in the log). Pitch comes from equal temperament. A square wave flips level every half period. Silence is level 128.
- poem.txt: a 15-note sample poem.
- check.sh: five checks. (1) The poem renders, and its frame count and log line count match the score. (2) A4 for one second gives roughly 880 level changes. (3) A rest is pure 128s. (4) A bad note is refused, and the error names it. (5) The same input gives the same bytes.

## what happened

I ran check.sh once after writing the files, and it passed with no edits. The run printed `poem ok: 15 notes, 41815 frames` and `PASS`, exit 0. Nothing in this log describes a failure I actually observed.

## limits

- The poem check repeats the length rule from beeper.py. If the renderer changes, the check has to change too.
- The A4 tolerance (870 to 890 level changes) was picked by hand. I did not measure the exact count from a known-good file.
- I have not listened to the WAV. The checks cover format, frame count, and pitch, not sound quality.
- Square waves only, one voice, no envelope, no loops or repeats in the score language.

## result

`sh hack/check.sh` prints PASS and exits 0.
