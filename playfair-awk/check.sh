#!/bin/sh
cd "$(dirname "$0")" || exit 1
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
fail() { echo "FAIL $*"; exit 1; }
# known vector: PLAYFAIR EXAMPLE / HIDETHEGOLDINTHETREESTUMP
echo "Hide the gold in the tree stump" | awk -v key="playfair example" -f playfair.awk > "$t/o"
[ "$(cat "$t/o")" = "BMODZBXDNABEKUDMUIXMMOUVIF" ] || fail "known vector: $(cat "$t/o")"
echo ok known vector
for n in 1 2 3 4 5 6 7 8 9 10 11 12; do
  python3 -I -c "
import random,string
r=random.Random($n)
print(''.join(r.choice(string.ascii_letters) for _ in range(r.randint(1,6))))
for _ in range(20): print(''.join(r.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.') for _ in range(r.randint(0,40))))" > "$t/in"
  key=$(head -1 "$t/in"); tail -n +2 "$t/in" > "$t/txt"
  awk -v key="$key" -f playfair.awk "$t/txt" > "$t/a"
  python3 -I ref.py "$key" e < "$t/txt" > "$t/b"
  cmp -s "$t/a" "$t/b" || fail "encrypt mismatch case $n"
  awk -v key="$key" -v mode=d -f playfair.awk "$t/a" > "$t/c"
  python3 -I ref.py "$key" d < "$t/a" > "$t/d"
  cmp -s "$t/c" "$t/d" || fail "decrypt mismatch case $n"
done
echo ok 12 random cases match python
sed 's/(ra + s) % 5; rb = (rb + s) % 5/ra; rb = rb/' playfair.awk > "$t/bad.awk"
cmp -s "$t/bad.awk" playfair.awk && fail "sabotage did not change file"
echo "Hide the gold in the tree stump" | awk -v key="playfair example" -f "$t/bad.awk" > "$t/o2"
[ "$(cat "$t/o2")" = "BMODZBXDNABEKUDMUIXMMOUVIF" ] && fail "sabotage not caught"
echo ok sabotage caught
echo PASS
