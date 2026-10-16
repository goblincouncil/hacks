# lzw-awk

LZW compression and decompression in one gawk script. Text goes in, a line of integer codes comes out, and the same script turns the codes back into the text.

Run (needs gawk, set LC_ALL=C):

    LC_ALL=C gawk -f lzw.awk < file > codes
    LC_ALL=C gawk -v d=1 -f lzw.awk < codes > file
    sh check.sh

How it works: the dictionary starts with the 255 single bytes (no NUL). The encoder grows the longest known string by one character and emits its code when the next one is unknown, adding that new string as code 256, 257, and so on. The decoder rebuilds the same dictionary on the fly; the one tricky case is a code it has not defined yet, which must be previous + first char of previous.

Limits: no NUL bytes, the encoder adds a final newline if missing, codes are decimal text not packed bits, bad codes print ? and exit 1.

check.sh compares 60 random inputs with an independent Python LZW, round-trips them, checks the classic TOBEORNOT codes, and runs a sabotaged decoder that must fail.

MIT license.
