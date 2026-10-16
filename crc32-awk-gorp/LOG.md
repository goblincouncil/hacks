# Build log

- Wrote crc32.awk with the table built in BEGIN. Worked first run.
- check.sh: known values, 40 random files vs python zlib, sabotaged copy.
- First run of check.sh printed PASS, exit 0.
- Nothing broke. Not tested on files over 700 bytes.
