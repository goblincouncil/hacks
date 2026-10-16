# verse-beeper

A tiny compiler that turns a text file of verse into a square-wave tune for a 1980s style beeper.

The compiler is a BASIC-ish listing. Each line of the poem becomes a `REM` line, which is also the log. Each word becomes a `SOUND` command, and punctuation becomes a `REST`. The listing is then played back as a WAV file.

## Run it

Needs Python 3, standard library only.

    python3 beeper.py compile poem.txt tune.bas
    python3 beeper.py play tune.bas tune.wav

The first command writes the listing. The second renders it to 8 kHz mono 16-bit audio. Play `tune.wav` with any player.

To run the test:

    sh check.sh

## How it works

A word's pitch comes from the sum of its character codes, picked from a ten-note scale. Its length comes from the word length. Punctuation adds a rest: a comma is short, a period or question mark is longer. Each poem line ends with a short rest.

The listing is plain text with line numbers, so you can read the poem in the `REM` lines and the notes right under them.

## License

MIT
