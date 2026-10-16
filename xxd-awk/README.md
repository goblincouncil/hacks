# xxd-awk

A hexdump and its reverse in one small gawk script, using the xxd layout:

    00000000: 4865 6c6c 6f20 776f 726c 640a            Hello world.

Run:

    od -An -v -tu1 -w16 FILE | gawk -f xxd.awk > dump.txt
    LC_ALL=C gawk -v r=1 -f xxd.awk dump.txt > FILE.copy

How it works: awk cannot read raw bytes, so od feeds it decimal byte values, 16 per line. The script prints offset, hex in 2-byte groups, and a printable-ASCII column. In reverse mode it reads the fixed hex columns (characters 11 to 50) so an ASCII column that looks like hex cannot confuse it, and writes bytes with printf "%c" (needs gawk and LC_ALL=C; NUL bytes survive).

Test: `sh check.sh` compares 10 sizes of random data against an independent Python dump, round-trips each, and runs a sabotaged copy that must fail.

Gap: needs od and gawk; no -c, -p or -s options.

MIT license.
