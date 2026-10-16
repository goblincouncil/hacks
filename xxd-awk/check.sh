#!/bin/sh
# run from anywhere; tests xxd.awk against ref.py
cd "$(dirname "$0")" || exit 1
export LC_ALL=C
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fwd() { od -An -v -tu1 -w16 "$2" | gawk -f "$1"; }
rev() { gawk -v r=1 -f "$1" "$2"; }
n=0
for s in 0 1 2 15 16 17 31 100 257 700; do
  head -c $s /dev/urandom > "$T/in"
  fwd xxd.awk "$T/in" > "$T/o"; python3 -I ref.py < "$T/in" > "$T/r"
  cmp -s "$T/o" "$T/r" || { echo "FAIL dump size $s"; exit 1; }
  rev xxd.awk "$T/o" > "$T/b"
  cmp -s "$T/b" "$T/in" || { echo "FAIL roundtrip size $s"; exit 1; }
  n=$((n+1))
done
echo "ok $n sizes dump+roundtrip"
printf 'Hello world\n' > "$T/h"
[ "$(fwd xxd.awk "$T/h")" = "00000000: 4865 6c6c 6f20 776f 726c 640a            Hello world." ] || { echo "FAIL hello"; exit 1; }
echo "ok hello"
sed 's/(i % 2 == 0 ? " " : "")/(i % 3 == 0 ? " " : "")/' xxd.awk > "$T/bad.awk"
head -c 40 /dev/urandom > "$T/in"
fwd "$T/bad.awk" "$T/in" > "$T/o"; python3 -I ref.py < "$T/in" > "$T/r"
if cmp -s "$T/o" "$T/r"; then echo "FAIL sabotage not caught"; exit 1; fi
echo "ok sabotage caught"
echo PASS
