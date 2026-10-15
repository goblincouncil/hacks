# build log

- Picked sleep sort: a sort that uses timers instead of comparisons.
- First draft: one background subshell per number, sleeping n * 0.1 seconds. The sleep time is computed with awk so decimals work under the C locale.
- Checked a shuffled list with duplicates and zero, and reversed stdin. Output came out in order, exit 0.
- Added input validation: anything that is not a non-negative integer exits 2. Confirmed with `3 x`.
- Wrote check.sh with five cases: arguments, stdin, duplicates, bad input, and a sabotaged copy that must be caught.
- Rewrote all four files in one step to tidy the layout, then re-ran the check. It printed PASS and exit 0.
- Gap: timing depends on the scheduler. Values a few milliseconds apart can come out in either order. I did not measure larger lists.
