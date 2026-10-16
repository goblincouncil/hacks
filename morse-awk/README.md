# morse-awk

Text to Morse code and back, in one awk script (`morse.awk`).

    echo "hello world" | awk -v mode=enc -f morse.awk
    echo ".... . .-.. .-.. --- / .-- --- .-. .-.. -.." | awk -v mode=dec -f morse.awk

Letters are separated by a space, words by ` / `. Letters and digits only; other characters are dropped when encoding, and unknown codes decode to `?`.

How it works: one comma-separated table is split into two associative arrays, one per direction. Encoding upper-cases each line and looks up characters; decoding splits on ` / ` for words, then on spaces for letters.

Test: `sh hack/check.sh` compares 300 random lines against an independent Python table, round-trips them, and confirms a copy with one wrong code is caught.

Gap: no punctuation.

MIT license.
