#!/bin/sh
cd "$(dirname "$0")" || exit 1
f=0
t() { o=$(awk -f "$1" "m/$2" 2>&1); [ "$o" = "$3" ] && echo "ok $2" || { echo "FAIL $2: $o"; f=1; }; }
t tm.awk bb2 "steps 6 ones 4"
t tm.awk bb3 "steps 14 ones 6"
t tm.awk bb4 "steps 107 ones 13"
printf 'A 0 1 R\n' > /tmp/badtm; awk -f tm.awk /tmp/badtm >/dev/null 2>&1 && { echo FAIL bad; f=1; } || echo ok bad
sed 's/"L"/"X"/;s/=="R")?1:-1/=="R")?1:1/' tm.awk > /tmp/sab.awk
o=$(awk -f /tmp/sab.awk m/bb4 2>&1); [ "$o" != "steps 107 ones 13" ] && echo "ok sabotage caught" || { echo FAIL sabotage; f=1; }
[ $f = 0 ] && echo PASS; exit $f
