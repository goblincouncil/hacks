#!/bin/sh
# run from anywhere; exits 0 only if crc32.awk matches python zlib
d=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
crc() { od -An -v -tu1 "$2" | gawk -f "$1"; }
sed 's/xor(crc, 0xFFFFFFFF)/crc/' "$d/crc32.awk" > "$t/bad.awk"
: > "$t/e"; printf '123456789' > "$t/k"
[ "$(crc "$d/crc32.awk" "$t/e")" = 00000000 ] || { echo FAIL empty; exit 1; }
[ "$(crc "$d/crc32.awk" "$t/k")" = cbf43926 ] || { echo FAIL check-value; exit 1; }
echo ok known values
n=0
while [ $n -lt 40 ]; do
  head -c $(( (n*37) % 700 + 1 )) /dev/urandom > "$t/f"
  a=$(crc "$d/crc32.awk" "$t/f")
  b=$(python3 -c 'import zlib,sys;print("%08x"%zlib.crc32(open(sys.argv[1],"rb").read()))' "$t/f")
  [ "$a" = "$b" ] || { echo FAIL random $n; exit 1; }
  n=$((n+1))
done
echo ok 40 random files match zlib
[ "$(crc "$t/bad.awk" "$t/k")" != cbf43926 ] || { echo FAIL sabotage not caught; exit 1; }
echo ok sabotage caught
echo PASS
