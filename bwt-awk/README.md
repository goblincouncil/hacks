# bwt-awk

The Burrows-Wheeler transform and its inverse in one gawk script (bwt.awk, about 1 KB).

Run it (one line of text per record):

    echo banana | gawk -v mode=enc -f bwt.awk     # annb$aa
    echo 'annb$aa' | gawk -v mode=dec -f bwt.awk  # banana

The `$` in the output marks where the hidden end marker landed, so input
containing `$` is refused (prints `?`, exit 1). Decoding needs exactly one `$`.

How it works: encode appends a marker (byte 1, sorts first), builds every
rotation, sorts them with asort, and keeps the last column. Decode sorts the
(character, position) pairs to get the first column and the next-pointer
for each row, then walks the chain from the marker row.

Check: `sh check.sh` compares 80 random lines to a separate Python version,
round-trips them, tests bad input, and runs a sabotaged copy that must fail.
Needs gawk and python3.

Gap: quadratic memory per line, meant for short lines.

MIT license.
