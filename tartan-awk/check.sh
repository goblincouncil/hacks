#!/bin/sh
# check.sh - exits 0 only if tartan.awk really weaves what the reference loom weaves.
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail=0
ok()  { echo "ok   $*"; }
bad() { echo "FAIL $*"; fail=1; }

SETTS='K4 R24 K24 Y4
R8
B6 W2
N3 G17 K9 W1 R5
G40 K30 B8 K6 W2
Y2 R60 N12
O1 A1 O1 P9
W13 K13
B24 K4 B4 K4 B4 K24 G24 Y6
R1'

# weave every sett with a given awk file, compare to loom.py; prints mismatch count
mismatches() {
  n=0
  echo "$SETTS" | while IFS= read -r s; do
    for size in 1 37 120; do
      awk -v sett="$s" -v size=$size -f "$1" > "$T/a.ppm" 2>/dev/null
      python3 loom.py "$s" $size > "$T/b.ppm"
      cmp -s "$T/a.ppm" "$T/b.ppm" || echo x
    done
  done | wc -l | tr -d ' '
}

# 1. the real loom matches the reference on 10 setts x 3 sizes
m=$(mismatches tartan.awk)
[ "$m" = 0 ] && ok "10 setts x 3 sizes match loom.py byte for byte" || bad "$m weaves differ from loom.py"

# 2. default output is a real 240x240 image
awk -v sett='K4 R24 K24 Y4' -f tartan.awk > "$T/d.ppm"
head -2 "$T/d.ppm" | tr '\n' ' ' | grep -q '^P3 240 240 $' && ok "default header is P3 240x240" || bad "default header wrong"
pix=$(tail -n +4 "$T/d.ppm" | wc -w | tr -d ' ')
[ "$pix" = $((240*240*3)) ] && ok "default image has $pix samples" || bad "sample count $pix"
if command -v magick >/dev/null 2>&1; then
  g=$(magick identify -format '%wx%h' "$T/d.ppm" 2>/dev/null)
  [ "$g" = 240x240 ] && ok "ImageMagick reads it as $g" || bad "ImageMagick says '$g'"
fi

# 3. twill sanity without Python: on a one-colour sett every pixel is that colour,
#    and with two colours the 2/2 twill puts warp on exactly half of each row
awk -v sett='G5' -v size=16 -f tartan.awk | tail -n +4 | tr ' ' '\n' | paste - - - | sort -u > "$T/u"
[ "$(cat "$T/u")" = "$(printf '20\t100\t40')" ] && ok "one-colour cloth is solid green" || bad "one-colour cloth not solid"
# sett R4 W4: two stripes are both pivots, so 8 threads R R R R W W W W.
# Row y=4 (file line 8): warp shows where x % 4 < 2, i.e. x = 0 1 4 5,
# giving R R W W; the other columns show weft thread 4, which is W.
row=$(awk -v sett='R4 W4' -v size=8 -f tartan.awk | sed -n 8p)
want='190 20 30 190 20 30 240 240 232 240 240 232 240 240 232 240 240 232 240 240 232 240 240 232'
[ "$row" = "$want" ] && ok "hand-woven row 4 of R4 W4 is right" || bad "row 4 of R4 W4: $row"

# 4. bad input is refused: nonzero exit, nothing on stdout
for s in '' 'K' 'k4' 'Q4' 'K0' 'K4 R' 'K4,R4' '4K'; do
  out=$(awk -v sett="$s" -f tartan.awk 2>/dev/null); rc=$?
  [ $rc -ne 0 ] && [ -z "$out" ] && ok "refuses sett '$s'" || bad "accepted sett '$s'"
done
out=$(awk -v sett=K4 -v size=abc -f tartan.awk 2>/dev/null); rc=$?
[ $rc -ne 0 ] && [ -z "$out" ] && ok "refuses size abc" || bad "accepted size abc"

# 5. sabotaged looms must be caught
sab() {
  sed "$2" tartan.awk > "$T/s.awk"
  if cmp -s tartan.awk "$T/s.awk"; then bad "sabotage '$1' did not change the file"; return; fi
  m=$(mismatches "$T/s.awk")
  [ "$m" != 0 ] && ok "sabotage caught: $1 ($m weaves differ)" || bad "sabotage missed: $1"
}
sab "plain weave instead of twill" 's/% 4 < 2/% 2 < 1/'
sab "warp and weft swapped"        's/th\[x % L\] : th\[y % L\]/th[y % L] : th[x % L]/'
sab "no mirror"                    's/for (i = m - 1; i >= 2; i--)/for (i = m - 1; i >= m + 2; i--)/'
sab "pivot stripes doubled"        's/i >= 2; i--/i >= 1; i--/'
sab "twill runs the wrong way"     's/(x + y) % 4/(x - y + 4000) % 4/'
sab "red is a little off"          's/"190 20 30"/"190 20 31"/'

if [ $fail = 0 ]; then echo PASS; exit 0; else echo FAIL; exit 1; fi
