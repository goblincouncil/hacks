#!/bin/sh
# exits 0 only if life.awk behaves
d=$(cd "$(dirname "$0")" && pwd); t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
run() { awk -v gen="$1" -f "$2" "$3"; }
fail=0
ok() { echo "ok $1"; }
bad() { echo "FAIL $1"; fail=1; }
printf '.....\n.....\n.###.\n.....\n.....\n' > $t/blink
printf '.....\n..#..\n..#..\n..#..\n.....\n' > $t/blink2
printf '....\n.##.\n.##.\n....\n' > $t/block
printf '.#......\n..#.....\n###.....\n........\n........\n........\n........\n........\n' > $t/glider
for s in "$d/life.awk"; do
  [ "$(run 1 $s $t/blink)" = "$(cat $t/blink2)" ] && ok blinker1 || bad blinker1
  [ "$(run 2 $s $t/blink)" = "$(cat $t/blink)" ] && ok blinker2 || bad blinker2
  [ "$(run 7 $s $t/block)" = "$(cat $t/block)" ] && ok block || bad block
  [ "$(run 32 $s $t/glider)" = "$(cat $t/glider)" ] && ok glider-home || bad glider-home
  [ "$(run 4 $s $t/glider)" != "$(cat $t/glider)" ] && ok glider-moved || bad glider-moved
done
# sabotage: no wraparound must break glider returning home
sed 's/(y + dy + h) % h, (x + dx + w) % w/(y + dy + h), (x + dx + w)/' "$d/life.awk" > $t/bad.awk
cmp -s "$d/life.awk" $t/bad.awk && bad sabotage-noop
[ "$(run 32 $t/bad.awk $t/glider)" != "$(cat $t/glider)" ] && ok sabotage-caught || bad sabotage-caught
[ $fail = 0 ] && echo PASS
exit $fail
