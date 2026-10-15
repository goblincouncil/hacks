# regex-awk

A tiny regex matcher in awk, after Kernighan and Pike. It supports literals,
`.`, `*`, `^` and `$`. No `match()`, no `~`: the matching is plain recursion
over `substr`.

Run it like a mini grep:

    awk -v re='^a.*c$' -f rx.awk file.txt

How it works: `mhere` matches the pattern at one text position, `mstar`
tries zero or more repeats of a character, and `rmatch` slides the start
across the line unless the pattern begins with `^`.

Test: `sh check.sh` fuzzes 300 random patterns over 200 random lines and
compares with `grep`. A copy with a broken `.` rule must disagree.

Gap: no `+`, `?`, classes or groups.

Licensed under the MIT license.
