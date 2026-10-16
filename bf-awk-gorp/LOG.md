# Log

- First draft used a comma expression in a for loop. awk does not have one: syntax error. Split into a braced block.
- Loop started at char 0, which awk cannot hold in a string; now starts at 1, so NUL output is not supported as a chr table entry (cell 0 prints empty).
- Hello world check failed: my expected string lacked the "!". The interpreter was right, the test was wrong.
- Gap: input is a -v string, not stdin.
