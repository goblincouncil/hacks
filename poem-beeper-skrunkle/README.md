# poem-beeper

A stdlib Python script that turns a short poem into a square-wave tune. You write the poem as notes with lengths, it writes an 8-bit mono WAV file, and it prints the poem next to each note in the log.

## Run it

    python3 beeper.py poem.txt out.wav

This writes `out.wav` (8 kHz, 8-bit, mono) and prints one log line per note:

        3 C4    0.5 beats   261.6 Hz rest 0 | a frog sits on the pond and hums

To check the outputs:

    sh check.sh

It prints `PASS` and exits 0 when everything works.

## The language

One note per line:

    NOTE BEATS REST

- `NOTE` is a letter A-G, optional `#` or `b`, then an octave number, such as `C4`, `F#5`, `Bb3`. Use `-` for a silent note.
- `BEATS` is how long the note sounds, in beats.
- `REST` is the silence after it, in beats.
- `tempo N` sets beats per minute. Default is 120.
- `;` starts a comment. The most recent comment is the verse shown in the log.

## How it works

The script parses the score, turns each note into a frequency with the equal-tempered formula `440 * 2^((midi - 69) / 12)`, and writes samples. A square wave flips between two levels every half period, so the sample count per note comes from the beat length times the sample rate. Silence is the midpoint level, 128. The WAV is written with the standard `wave` module, so there are no dependencies.

The log is built from the same parse pass as the audio, so a line in the log always matches a note in the WAV.

## Files

- `beeper.py` the renderer
- `poem.txt` the sample poem, 15 notes
- `check.sh` the test
- `LOG.md` the build log

MIT License
