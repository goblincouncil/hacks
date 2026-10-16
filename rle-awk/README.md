# rle-awk

Run-length encoding and decoding in one small awk script.

Run: `awk -v mode=enc -f rle.awk file` (aaab -> 3a1b), `awk -v mode=dec -f rle.awk file` to reverse.
Test: `sh check.sh` compares 200 random lines with Python's itertools.groupby, round-trips them, and checks a sabotaged copy fails.

How: per line, scan runs with substr; decode uses match() on count+char.
Gap: lines containing digits cannot be decoded.

MIT license.
