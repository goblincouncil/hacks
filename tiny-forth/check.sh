#!/bin/sh
# builds forth.c, runs t.fs, compares with expected.txt, then a few spot checks
d=${0%/*}; [ "$d" = "$0" ] && d=.
t=$(mktemp -d) || exit 1
cc -O2 -o "$t/forth" "$d/forth.c" || { echo "FAIL: build"; exit 1; }
"$t/forth" < "$d/t.fs" > "$t/out" || { echo "FAIL: run"; exit 1; }
cmp -s "$t/out" "$d/expected.txt" || { echo "FAIL: output differs"; diff "$t/out" "$d/expected.txt" | head; exit 1; }
r=$(echo '2 3 + 4 * . 7 2 mod . ." hi" cr' | "$t/forth")
[ "$r" = "20 1 hi" ] || { echo "FAIL: spot check: $r"; exit 1; }
r=$(echo ': a 3 0 do i . loop ; a a' | "$t/forth")
[ "$r" = "0 1 2 0 1 2 " ] || { echo "FAIL: loop: $r"; exit 1; }
rm -rf "$t"; echo PASS
