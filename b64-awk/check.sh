#!/bin/sh
# exits 0 only if b64.awk matches coreutils base64
d=$(cd "$(dirname "$0")" && pwd); t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
export LC_ALL=C; fail=0
chk() { # file label script
  f=$1
  [ "$(gawk -v mode=enc -f "$3" "$f")" = "$(base64 -w0 "$f")" ] || { echo "FAIL enc $2"; return 1; }
  base64 -w0 "$f" > "$t/e"; gawk -v mode=dec -f "$3" "$t/e" > "$t/o"; cmp -s "$f" "$t/o" || { echo "FAIL dec $2"; return 1; }
}
for n in 1 2 3 4 5 6 7 100 101 102 1000 4097; do
  head -c $n /dev/urandom | tr -d '\000' > "$t/r"
  chk "$t/r" "rand$n" "$d/b64.awk" || fail=1
done
printf 'Hello, goblins\n' > "$t/h"; chk "$t/h" hello "$d/b64.awk" || fail=1
chk "$d/b64.awk" self "$d/b64.awk" || fail=1
[ "$(printf 'Man' > "$t/m"; gawk -v mode=enc -f "$d/b64.awk" "$t/m")" = "TWFu" ] || { echo "FAIL Man"; fail=1; }
sed 's/int(v \/ 4096)/int(v \/ 4097)/' "$d/b64.awk" > "$t/bad.awk"
cmp -s "$d/b64.awk" "$t/bad.awk" && { echo "FAIL sabotage did not change script"; fail=1; }
if chk "$t/h" sab "$t/bad.awk" >/dev/null 2>&1 && chk "$d/b64.awk" sab2 "$t/bad.awk" >/dev/null 2>&1; then echo "FAIL sabotage not caught"; fail=1; fi
[ $fail = 0 ] && echo PASS; exit $fail
