#!/bin/sh
# exits 0 only if lzw.awk matches the Python reference and round-trips
cd "$(dirname "$0")" || exit 1
export LC_ALL=C
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL $1"; exit 1; }
printf 'TOBEORNOTTOBEORTOBEORNOT' | gawk -f lzw.awk | tr -d ' \n' | grep -q . || fail empty
got=$(printf 'TOBEORNOTTOBEORTOBEORNOT\n' | gawk -f lzw.awk)
want="84 79 66 69 79 82 78 79 84 256 258 260 265 259 261 263 10"
[ "$got" = "$want" ] || fail "classic: $got"
echo "ok classic codes"
i=0
while [ $i -lt 60 ]; do
  python3 -I -c "
import random,sys
r=random.Random($i);n=r.choice([0,1,5,100,700,3000]);a=r.choice([b'ab',b'abc\n',bytes(range(1,256))])
d=bytes(r.choice(a) for _ in range(n))
if d and not d.endswith(b'\n'): d+=b'\n'
sys.stdout.buffer.write(d)" > "$T/in"
  gawk -f lzw.awk < "$T/in" > "$T/c" || fail "enc $i"
  python3 -I ref.py < "$T/in" > "$T/r"
  cmp -s "$T/c" "$T/r" || fail "ref mismatch seed $i"
  gawk -v d=1 -f lzw.awk < "$T/c" > "$T/o" || fail "dec $i"
  cmp -s "$T/o" "$T/in" || fail "roundtrip seed $i"
  i=$((i+1))
done
echo "ok 60 files match reference and round-trip"
echo "999" | gawk -v d=1 -f lzw.awk >/dev/null 2>&1 && fail "bad code accepted"
echo "ok bad code rejected"
# sabotage: break the KwKwK case; must fail on aaaa input
sed 's/e = w substr(w, 1, 1)/e = w/' lzw.awk > "$T/bad.awk"
printf 'aaaaaaaaaa\n' | gawk -f lzw.awk > "$T/c"
printf 'aaaaaaaaaa\n' > "$T/a"
if gawk -v d=1 -f "$T/bad.awk" < "$T/c" 2>/dev/null | cmp -s - "$T/a"; then fail "sabotage not caught"; fi
echo "ok sabotage caught"
echo PASS
