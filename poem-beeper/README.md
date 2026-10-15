# poem-beeper

A small compiler that turns a short poem into a .wav of PC-speaker beeps.

It reads a plain text poem and plays it back as square waves, the sound an old
IBM PC made through its one-bit speaker. Each word becomes one note. Run it, then
listen to the .wav.

## Run it

Needs only Python 3. No packages.

    cd hack
    python3 beeper.py poem.txt poem.wav poem.log

The first argument is the poem, the second is the .wav to write, and the optional
third is a log file. Without a third argument the log goes to stdout.

To check the whole thing:

    sh hack/check.sh

## What is here

- beeper.py   the compiler, about 100 lines
- poem.txt    the poem it ships with
- poem.wav    the poem, compiled (8-bit mono, 22050 Hz)
- poem.log    the log from that compile: every word, its pitch, its length
- check.sh    renders the poem twice, checks the output is identical, checks the
              WAV header and the two square-wave levels, and checks the log
              quotes every line of the poem

## How it works

The rule from text to sound is short, and it is the whole design:

1. Each word is one note.
2. The pitch comes from the letters. Add up the character codes of the word, then
   take that sum modulo 10. The result picks one of ten notes from a fixed ladder
   (C, D, E, G, A and their octave repeats, roughly a pentatonic scale).
3. The length comes from the vowels. A word gets one unit plus one unit per vowel
   (a, e, i, o, u, y), so "strings" is short and "nothing" is long.
4. The punctuation after a word sets the rest that follows it. A comma or dash is
   a short gap, a full stop, question mark or bang is a long gap, and anything
   else is a tiny gap so words do not run together.

The waveform is a square wave made by hand. The sample at position i is the high
level or the low level depending on whether floor(2 * i * freq / rate) is even.
There is no mixing, no envelope, no filter. The output is the same bytes every
time, which is why check.sh can compare two runs with cmp.

The log lists each note with its start time, word, frequency, length and rest, so
you can read the poem back as numbers.

## License

MIT License. Copyright (c) 2026 goblincouncil. See the line below.

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software, to deal in it without restriction, subject to the MIT License terms.
