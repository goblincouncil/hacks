#!/bin/sh
# check.sh: exits 0 only if ant.awk draws Langton's ant correctly as sixel.
# Each picture is decoded by ref.py (its own ant, its own sixel decoder)
# and compared pixel for pixel. Sabotaged copies of ant.awk must fail.
set -u
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "ok   $*"; }
bad() { echo "FAIL $*"; fail=1; }

for f in ant.awk ref.py README.md LOG.md NAME; do
    test -s "$f" || bad "missing $f"
done

# 1. correct pictures for several step counts and scales
for case in "0 1" "1 3" "5 2" "100 1" "500 2" "2000 1" "11000 1" "11000 4"; do
    set -- $case
    awk -v steps="$1" -v scale="$2" -f ant.awk > "$T/a.six" || { bad "awk steps=$1 scale=$2"; continue; }
    out=$(python3 -I ref.py check "$1" "$2" "$T/a.six" 2>&1)
    if [ $? -eq 0 ]; then ok "steps=$1 scale=$2 $out"; else bad "steps=$1 scale=$2 $out"; fi
done

# 2. defaults are 11000 steps at scale 4
awk -f ant.awk > "$T/d.six"
out=$(python3 -I ref.py check 11000 4 "$T/d.six" 2>&1) && ok "defaults $out" || bad "defaults $out"

# 3. the highway: the picture keeps growing after the chaotic phase
w1=$(awk -v steps=10000 -v scale=1 -f ant.awk | sed -n 's/.*"1;1;\([0-9]*\);\([0-9]*\).*/\1/p')
w2=$(awk -v steps=11000 -v scale=1 -f ant.awk | sed -n 's/.*"1;1;\([0-9]*\);\([0-9]*\).*/\1/p')
if [ -n "$w1" ] && [ -n "$w2" ] && [ "$w2" -gt "$w1" ]; then ok "highway grows: width $w1 -> $w2"; else bad "highway width $w1 -> $w2"; fi

# 4. a second opinion: ImageMagick decodes the sixel too
if command -v convert >/dev/null 2>&1; then
    awk -v steps=11000 -v scale=2 -f ant.awk > "$T/m.six"
    if convert "$T/m.six" -depth 8 "ppm:$T/m.ppm" 2>/dev/null; then
        out=$(python3 -I ref.py ppm 11000 2 "$T/m.ppm" 2>&1) && ok "imagemagick $out" || bad "imagemagick $out"
    else
        bad "imagemagick could not read the sixel"
    fi
else
    echo "skip imagemagick not installed"
fi

# 5. sabotaged copies must be caught
sabotage() { # name, sed expression
    sed "$2" ant.awk > "$T/s.awk"
    if cmp -s ant.awk "$T/s.awk"; then bad "sabotage '$1' did not change the script"; return; fi
    awk -v steps=11000 -v scale=2 -f "$T/s.awk" > "$T/s.six" 2>/dev/null
    if python3 -I ref.py check 11000 2 "$T/s.six" >/dev/null 2>&1; then
        bad "sabotage '$1' was not caught"
    else
        ok "sabotage '$1' caught"
    fi
}
sabotage "turns swapped" 's/d = (d + 3) % 4/d = (d + 5) % 4/'
sabotage "bits upside down" 's/bits += 2 ^ r/bits += 2 ^ (5 - r)/'
sabotage "repeat off by one" 's/return "!" n ch/return "!" (n - 1) ch/'
sabotage "ant not drawn" 's/return 2$/return 1/'

if [ $fail -eq 0 ]; then echo PASS; exit 0; fi
echo FAILED; exit 1
