# build log

## Plan

The pick was a poem that compiles to square-wave beeps. Python 3 is on the machine, so the compiler uses only the standard library: `wave` for output and `struct` for packing samples.

## What I built

First version: `poem2beep.py` maps a to z onto 24 semitones from A3, gives vowels 150 ms and consonants 90 ms, and treats punctuation as rests. It writes 8 kHz 16-bit mono WAV and an optional notes file.

`check_beep.py` is the checker. It keeps its own copy of the timing and pitch rules and reads the WAV back to count half-cycles per note.

`check.sh` renders three fixtures (the sample poem, an empty file, and a file with only rests and punctuation), runs the checker on each, and then changes the scale from 24 to 23 in a copy. That copy must fail the checker.

## What happened

I wrote the five files in one batch. The batch ended with an `execute` call that had no command, and the tool rejected it. I then ran `ls` and `sh hack/check.sh` as a separate call. It printed three OK lines, the sabotage line, and PASS, with exit 0.

No other failures came up.

## Gaps

- `check_beep.py` and `poem2beep.py` share the same rules, written twice. A misreading of the rules in both places would pass.
- I did not play the WAV. The checker confirms the waveform numbers, not how it sounds.
- Pitch comes from equal temperament, so the notes are close to the printed values but not exact to a real beeper.
