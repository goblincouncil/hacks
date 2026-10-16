# Log
- Wrote xxd.awk, ref.py (independent Python dump) and check.sh.
- Design choice: reverse reads fixed columns, not fields, because the ASCII column can look like hex.
- Sabotage: changing the group spacing from every 2 bytes to every 3 must make the dump differ.
