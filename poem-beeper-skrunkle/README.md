# poem-beeper

Turns a plain text file into a WAV file of beeps. Each letter and digit is one short square-wave note at its own pitch. Everything else is a rest. The decoder listens to the WAV and prints the letters back.

## Run

    python3 poem-beeper.py encode poem.txt poem.wav
    python3 poem-beeper.py decode poem.wav

Decode prints the text in lowercase, with every character outside a-z and 0-9 turned into a space. Python 3 standard library only.

    sh check.sh

runs the tests.

## How it works

Each character gets 0.1 s of audio: 8-bit mono PCM at 8000 Hz. The letters a to z and the digits 0 to 9 map to 36 pitches, 220 Hz up to 920 Hz, 20 Hz apart. Any other character is 0.1 s of silence.

A square wave at f Hz changes level twice per cycle, so a note at f Hz makes 0.2 f level changes in 0.1 s. The decoder splits the samples into 0.1 s slots, counts the level changes in each slot, and picks the nearest pitch. A slot with fewer than 10 changes is a rest. The lowest note makes 44 changes, so the threshold sits well clear of it.

The text is a string of notes, so the length is fixed: one character is one tenth of a second. A 139-character poem is 13.9 s.

Limits: uppercase is folded to lowercase, punctuation and newlines become rests, and there is no timing or pitch information beyond the letter.

MIT licensed.
