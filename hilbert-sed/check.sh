#!/bin/sh
# check.sh: exit 0 only if hilbert.sed + turtle.awk really draw the Hilbert curve.
set -u
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }

# match SEDFILE AWKFILE TAG: orders 1..7 against ref.py, one symmetry for all
match() {
  files=""
  for n in 1 2 3 4 5 6 7; do
    echo "$n" | sed -f "$1" | awk -v points=1 -f "$2" > "$tmp/$3.$n" 2>/dev/null || return 1
    files="$files $tmp/$3.$n"
  done
  python3 -I "$here/ref.py" --compare $files > "$tmp/$3.cmp" 2>&1
}

S="$here/hilbert.sed"; A="$here/turtle.awk"

if match "$S" "$A" real; then ok "orders 1-7 match ref.py point for point ($(cat "$tmp/real.cmp"))"
else bad "orders 1-7 do not match ref.py: $(cat "$tmp/real.cmp" 2>/dev/null)"; fi

for n in 1 2 3 4 5 6 7 8; do
  f=$(echo "$n" | sed -f "$S" | tr -cd F | wc -c)
  want=$(( (1 << (2 * n)) - 1 ))
  if [ "$f" -eq "$want" ]; then ok "order $n has $want steps"; else bad "order $n has $f steps, want $want"; fi
done

echo 3 | sed -f "$S" | awk -f "$A" > "$tmp/o3.svg"
if python3 -I -c '
import sys, xml.etree.ElementTree as ET
r = ET.parse(sys.argv[1]).getroot()
assert r.get("width") == "64" and r.get("height") == "64", (r.get("width"), r.get("height"))
pl = [e for e in r.iter() if e.tag.endswith("polyline")]
assert len(pl) == 1 and len(pl[0].get("points").split()) == 64
' "$tmp/o3.svg"; then ok "order 3 SVG parses, 64x64 px, 64 points"; else bad "order 3 SVG is wrong"; fi

for input in x 0 10 ""; do
  echo "$input" | sed -f "$S" > /dev/null 2>&1
  if [ $? -eq 2 ]; then ok "sed refuses order '$input'"; else bad "sed accepted order '$input'"; fi
done
echo "FFX" | awk -f "$A" > /dev/null 2>&1
if [ $? -eq 2 ]; then ok "turtle refuses a bad command"; else bad "turtle accepted a bad command"; fi

# sabotage: each broken copy must differ from the original and must fail
grep -v -F 's/A/X/g' "$S" | grep -v -F 's/B/Y/g' | sed 's#s/X/#s/A/#; s#s/Y/#s/B/#' > "$tmp/bad1.sed"
sed 's#AFA-FB+#AFA+FB-#' "$S" > "$tmp/bad2.sed"
sed 's#t = dx; dx = -dy; dy = t#t = dx; dx = dy; dy = -t#' "$A" > "$tmp/bad3.awk"
sab() {
  if cmp -s "$2" "$3"; then bad "sabotage $1 did not change anything"; return; fi
  if match "$4" "$5" "$1"; then bad "sabotage $1 was not caught"; else ok "sabotage $1 is caught"; fi
}
sab no-parking "$S" "$tmp/bad1.sed" "$tmp/bad1.sed" "$A"
sab flipped-rule "$S" "$tmp/bad2.sed" "$tmp/bad2.sed" "$A"
sab left-is-right "$A" "$tmp/bad3.awk" "$S" "$tmp/bad3.awk"

if [ "$fail" -eq 0 ]; then echo PASS; exit 0; fi
echo FAIL; exit 1
