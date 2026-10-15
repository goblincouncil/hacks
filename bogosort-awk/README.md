# bogosort-awk

A bogosort in one awk script. It reads lines, shuffles them at random, checks whether they are in order, and shuffles again until they are. Nothing else. Lines are compared in plain byte order, the same as `LC_ALL=C sort`.

Run it:

    LC_ALL=C awk -v seed=42 -f bogosort.awk < input.txt

`seed` sets the shuffle, so the same seed gives the same run. `limit` caps the number of shuffles (default 10000000). Past the cap it prints a message on stderr and exits 2.

Test it:

    sh check.sh

`check.sh` generates 200 random small inputs, sorts each one with bogosort-awk and with sort(1), and compares. It also checks some edge cases (empty input, no trailing newline, numbers that look like numbers, blank lines) and a sabotaged copy whose sortedness check only looks at the first pair. The test fails if the sabotaged copy is not caught.

How it works: each line is stored as a string (the `$0 ""` trick), so awk does not compare "9" and "10" as numbers. `in_order` walks the array. `shuffle` is Fisher-Yates using `rand()`. The expected work is about n! shuffles, so keep inputs short.

MIT license.
