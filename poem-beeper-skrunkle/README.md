# poem-beeper

A tiny compiler that turns a text poem into a square-wave tune for a beeper.

Run it:

    python3 beep.py examples/poem.txt out.wav

It prints the poem back to stdout with every note listed under its line, then writes a mono 22050 Hz, 16-bit WAV file. Play it with any audio player.

The input is plain text. Lines without a leading number are verse, and each line becomes one bar. A line that starts with a number is a statement. The only statement is `TEMPO`:

    10 TEMPO 132

Tempo must be between 30 and 300. Anything else is a compile error that names the line number.

How it works: each word picks a pitch from the sum of its letter codes, mapped onto a major pentatonic scale over A2. Each word's length comes from its vowel count. Commas and semicolons are short rests, full stops and question marks are long rests, and each line ends with a short gap. The output is a plain square wave at fixed amplitude, so the same poem always gives the same bytes.

Requires Python 3. No other dependencies.

Run the test with `sh hack/check.sh`.

MIT License
