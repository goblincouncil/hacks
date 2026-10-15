# Log
- Picked bf-awk. Wrote bf.awk with RS set to \001 so the program file is read whole by getline.
- First run of hello.bf printed fine; a combined shell call looked odd only because output had no trailing newline.
- Wrote ref.py as a separate interpreter and check.sh against it.
- Gaps: slow (squares takes a moment), tape grows right without limit, no `#` comments beyond ignoring non-command characters.
