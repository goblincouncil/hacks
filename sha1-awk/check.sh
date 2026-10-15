#!/bin/sh
d=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
fail=0
cmp1() { # file label script
  a=$(SHA1_AWK=$3 sh "$d/sha1.sh" "$1"); b=$(sha1sum <"$1" | cut -d' ' -f1)
  if [ "$a" = "$b" ]; then echo "ok $2"; else echo "FAIL $2 ($a vs $b)"; return 1; fi
}
: >"$t/empty"; printf abc >"$t/abc"; printf '\0\0\0' >"$t/nul"
for n in 55 56 63 64 65 119 120 1000; do head -c $n /dev/zero | tr '\0' 'x' >"$t/l$n"; done
head -c 3000 /dev/urandom >"$t/rand"
cp "$d/sha1.awk" "$t/self"
for f in "$t"/*; do cmp1 "$f" "$(basename "$f")" "$d/sha1.awk" || fail=1; done
sed 's/rol(b, 30)/rol(b, 29)/' "$d/sha1.awk" >"$t/bad.awk"
if cmp1 "$t/abc" sabotage "$t/bad.awk" >/dev/null; then echo "FAIL sabotage not caught"; fail=1; else echo "ok sabotage caught"; fi
[ $fail = 0 ] && echo PASS || { echo FAILED; exit 1; }
