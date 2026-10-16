#!/bin/sh
# check.sh: exits 0 only if magiceye.awk really works.
set -u
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL $*"; exit 1; }
ok() { echo "ok $*"; }

for t in awk python3; do command -v $t >/dev/null || fail "missing $t"; done

# 1. the sample map, defaults, against the Python twin
awk -f magiceye.awk goblin.map > "$T/a" || fail "awk exited nonzero on goblin.map"
python3 twin.py goblin.map > "$T/p" || fail "twin exited nonzero"
cmp -s "$T/a" "$T/p" || fail "goblin.map differs from twin"
ok "goblin.map matches the Python twin"

# 2. output shape: same rows as the map, each P + width long, letters only
rows=$(wc -l < goblin.map)
[ "$(wc -l < "$T/a")" -eq "$rows" ] || fail "row count"
awk -v w=76 'length($0) != w || /[^A-Za-z]/ { bad = 1 } END { exit bad }' "$T/a" || fail "row width or alphabet"
ok "shape: $rows rows of 76 letters"

# 3. the blind decoder pulls the sample map back exactly
python3 decode.py "$T/a" > "$T/d" || fail "decoder crashed"
cmp -s "$T/d" goblin.map || fail "decoder did not recover goblin.map"
ok "decoder recovers goblin.map exactly"

# 4. random block maps at several periods and seeds: twin match and decode
python3 gen_maps.py "$T" 30 || fail "gen_maps"
n=0
for m in "$T"/map*.txt; do
  i=$(basename "$m" .txt); i=${i#map}
  P=$((10 + i * 7 % 90)); S=$((i * 7919 + 1))
  awk -v P=$P -v seed=$S -f magiceye.awk "$m" > "$T/a" || fail "awk on $m"
  python3 twin.py "$m" $P $S > "$T/p" || fail "twin on $m"
  cmp -s "$T/a" "$T/p" || fail "$m P=$P seed=$S differs from twin"
  python3 decode.py "$T/a" $P > "$T/d$i" || fail "decode on $m"
  n=$((n + 1))
done
[ $n -eq 30 ] || fail "only $n random maps ran"
ok "$n random maps match the Python twin byte for byte"

# The decoder is blind, and with 52 letters a wrong repeat distance can match
# by luck, so a few cells at depth edges may come back wrong. Demand at least
# 99 percent overall, 95 percent on every map, and no '?' anywhere.
res=$(python3 - "$T" <<'EOF'
import sys
t = sys.argv[1]
tot = bad = 0
worst = 1.0
for i in range(30):
    got = open(f"{t}/d{i}").read().split("\n")
    want = open(f"{t}/map{i}.txt.full").read().split("\n")
    if len(got) != len(want) or any(len(a) != len(b) for a, b in zip(got, want)):
        print("shape", i); sys.exit(1)
    if any("?" in a for a in got):
        print("unfusable", i); sys.exit(1)
    n = sum(len(b) for b in want)
    e = sum(p != q for a, b in zip(got, want) for p, q in zip(a, b))
    tot += n; bad += e; worst = min(worst, 1 - e / n)
print(tot - bad, tot, f"{worst:.3f}")
sys.exit(0 if (tot - bad) / tot >= 0.99 and worst >= 0.95 else 1)
EOF
) || fail "decoder accuracy too low: $res"
set -- $res
ok "decoder recovers $1 of $2 random-map cells, worst map $3"

# 5. same seed repeats, different seed differs
awk -v seed=5 -f magiceye.awk goblin.map > "$T/s1"
awk -v seed=5 -f magiceye.awk goblin.map > "$T/s2"
awk -v seed=6 -f magiceye.awk goblin.map > "$T/s3"
cmp -s "$T/s1" "$T/s2" || fail "same seed gave different output"
cmp -s "$T/s1" "$T/s3" && fail "different seeds gave the same output"
ok "seeds are repeatable and distinct"

# 6. bad input is refused with exit 1 and no output
printf '12x4\n' > "$T/bad1"; : > "$T/bad2"; printf '1-2\n' > "$T/bad3"
for c in "$T/bad1" "$T/bad2" "$T/bad3" "-v P=9 goblin.map" "-v P=100 goblin.map" \
         "-v P=1x goblin.map" "-v seed=0 goblin.map" "-v seed=-3 goblin.map"; do
  # shellcheck disable=SC2086
  out=$(awk -f magiceye.awk $c 2>/dev/null); rc=$?
  [ $rc -eq 1 ] || fail "bad input '$c' gave rc=$rc"
  [ -z "$out" ] || fail "bad input '$c' printed output"
  nb=$((${nb:-0} + 1))
done
ok "$nb bad inputs refused"

# 7. sabotaged copies must be caught by the twin or the decoder
s=0
sabo() {
  sed "$1" magiceye.awk > "$T/sab.awk"
  cmp -s magiceye.awk "$T/sab.awk" && fail "sabotage '$1' did not change the script"
  awk -f "$T/sab.awk" goblin.map > "$T/sa" 2>/dev/null
  if cmp -s "$T/sa" "$T/p0"; then fail "sabotage '$1' was not caught"; fi
  s=$((s + 1))
}
python3 twin.py goblin.map > "$T/p0"
sabo 's/c\[x - P + d\]/c[x - P - d]/'
sabo 's/c\[x - P + d\]/c[x - P]/'
sabo 's/% 52 + 1/% 51 + 1/'
sabo 's/16807/16808/'
sabo 's/x - P, 1)/x - P + 1, 1)/'
sabo 's/x <= P + W/x < P + W/'
ok "$s sabotaged copies caught"

# 8. a corrupted stereogram is flagged by the decoder
awk -f magiceye.awk goblin.map | sed '3s/^\(.\{40\}\)./\1!/' > "$T/cor"
python3 decode.py "$T/cor" | grep -q '?' || fail "decoder did not flag a corrupted letter"
ok "corrupted letter flagged by the decoder"

echo PASS
