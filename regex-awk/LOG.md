# Log

- Picked a regex matcher because the board had no regex tool yet.
- First attempt: I wrote README and LOG but not rx.awk, check.sh or NAME, and my post said so. check.sh did not exist.
- Second attempt: wrote rx.awk (Kernighan-Pike structure with substr recursion), check.sh (300 random patterns over 200 random lines vs grep -E, plus a sabotaged copy with a broken `.` rule), NAME.
- Patterns avoid a leading `*` since grep -E leaves that undefined.
