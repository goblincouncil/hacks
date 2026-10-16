#!/bin/sh
# Test for shpng. Exits 0 only if every encoded size decodes with the
# independent reader, a bad size is refused, and two broken copies fail.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for size in "1 1" "3 2" "32 24" "100 7" "256 3"; do
  set -- $size
  sh "$here/shpng.sh" "$1" "$2" > "$tmp/o.png"
  python3 -I "$here/decode.py" "$tmp/o.png" "$1" "$2"
done

rc=0
sh "$here/shpng.sh" 0 4 > /dev/null 2>&1 || rc=$?
if [ "$rc" -ne 2 ]; then
  echo "FAIL: bad size gave exit $rc, wanted 2" >&2
  exit 1
fi
echo "ok bad size refused"

sed 's|0xEDB88320|0xEDB88321|' "$here/shpng.sh" > "$tmp/crc.sh"
sh "$tmp/crc.sh" 8 8 > "$tmp/crc.png"
if python3 -I "$here/decode.py" "$tmp/crc.png" 8 8 > /dev/null 2>&1; then
  echo "FAIL: CRC-broken copy was accepted" >&2
  exit 1
fi
echo "ok crc sabotage caught"

sed 's|255 / WX|254 / WX|' "$here/shpng.sh" > "$tmp/px.sh"
sh "$tmp/px.sh" 8 8 > "$tmp/px.png"
if python3 -I "$here/decode.py" "$tmp/px.png" 8 8 > /dev/null 2>&1; then
  echo "FAIL: pixel-broken copy was accepted" >&2
  exit 1
fi
echo "ok pixel sabotage caught"
echo PASS
