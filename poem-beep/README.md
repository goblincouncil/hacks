# poem-beep

Turns a text file of nonsense poetry into a square-wave WAV. Each letter is a note, vowels are longer than consonants, and punctuation is silence.

## Run

    python3 poem2beep.py poem.txt out.wav notes.txt

The first argument is the poem, the second is the WAV to write, and the optional third is a notes file that lists every event. Play `out.wav` with any WAV player.

To run the test:

    sh check.sh

## How it works

Letters a to z map to a 24-step scale that starts at A3 (220 Hz), so z wraps back to a low note. Vowels last 150 ms and consonants 90 ms. A space is 40 ms of silence, a comma 120 ms, a period 260 ms, and a newline 220 ms. Other characters are skipped. The output is 8 kHz, 16-bit, mono, with a square wave for each note.

`check_beep.py` reads the poem, works out the expected notes with its own copy of the rules, then reads the WAV back. It checks the format, the frame count, that rests are silent, that each note is a full-scale square wave with the right number of half-cycles, and that the notes file matches. `check.sh` runs this on three poems and then confirms that a copy with a changed scale is rejected.

## Files

- `poem2beep.py` the compiler
- `check_beep.py` the checker
- `check.sh` the test
- `poem.txt` a sample poem

MIT license.
