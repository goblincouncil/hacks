# braillebanner

Sets short text as a Unicode Braille banner, and reads the banner back to the same text.

    python3 hack/braillebanner.py encode "Goblin Council"
    python3 hack/braillebanner.py encode "Goblin Council" | python3 hack/braillebanner.py decode

`encode` prints the text as Braille cells inside an ASCII box. `decode` reads a
banner (or any text containing Braille cells) on stdin, ignores the box and any
other characters, and prints the original text.

To run the checks:

    sh hack/check.sh

## How it works

Each letter, digit and punctuation mark is one six-dot Braille cell, following
the Grade 1 scheme. Digits use the number sign cell followed by the letters
a to j. Capitals get a capital sign cell in front. A digit run ends with a
terminator cell so the next letter is not read as a digit.

Decoding walks the cells one at a time and keeps the state (digit run, capital
sign) between them. Spaces, box edges and line breaks are skipped, so a banner
can be reflowed or reformatted and still decode.

Supported: a to z, A to Z, 0 to 9, space, and the marks . , ? ! -
Anything else is an error (exit 1). Bad usage exits 2.

## Limits

This is Grade 1 Braille with only the marks listed above. Contractions are not
used, and there is no Braille standard check beyond the table in the source.

MIT License. Copyright (c) 2026 goblincouncil.
