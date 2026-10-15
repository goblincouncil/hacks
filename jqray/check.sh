#!/bin/sh
# check.sh: exits 0 only if jqray.jq really renders the scene.
# 1. jq output is a well-formed P3 image of the right size
# 2. it matches the independent Python twin byte for byte, at two sizes
# 3. the picture has a green ball, a red/white floor and a blue-white sky
# 4. sabotaged copies of the tracer are caught
set -u
DIR=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }

command -v jq >/dev/null || { echo "FAIL jq not found"; exit 1; }
command -v python3 >/dev/null || { echo "FAIL python3 not found"; exit 1; }

if jq -n -r -f "$DIR/jqray.jq" > "$T/a.ppm"; then ok "jq renders 160x120"; else bad "jq failed"; fi
(cd "$T" && python3 -I "$DIR/twin.py" > "$T/b.ppm") || bad "twin failed"

if cmp -s "$T/a.ppm" "$T/b.ppm"; then ok "jq == python twin at 160x120"; else bad "jq and twin differ at 160x120"; fi

jq -n -r --argjson w 41 --argjson h 29 -f "$DIR/jqray.jq" > "$T/a2.ppm" || bad "jq failed at 41x29"
(cd "$T" && python3 -I "$DIR/twin.py" 41 29 > "$T/b2.ppm") || bad "twin failed at 41x29"
if cmp -s "$T/a2.ppm" "$T/b2.ppm"; then ok "jq == python twin at 41x29"; else bad "jq and twin differ at 41x29"; fi

# structure and content of the jq image, judged without the tracer's code
if python3 -I - "$T/a.ppm" <<'EOF'
import sys
t = open(sys.argv[1]).read().split()
assert t[0] == "P3" and t[1:4] == ["160", "120", "255"], "bad header"
v = list(map(int, t[4:]))
assert len(v) == 160 * 120 * 3, "wrong pixel count"
assert all(0 <= x <= 255 for x in v), "value out of range"
px = lambda x, y: v[3 * (y * 160 + x):3 * (y * 160 + x) + 3]
r, g, b = px(5, 2)
assert b > 240 and r > 180 and b >= g >= r, "sky is not blue-white: %r" % [r, g, b]
green = sum(1 for i in range(0, len(v), 3) if v[i + 1] > v[i] + 40 and v[i + 1] > v[i + 2] + 20)
red = sum(1 for i in range(0, len(v), 3) if v[i] > v[i + 1] + 40 and v[i] > v[i + 2] + 40)
assert green > 300, "no green ball (%d px)" % green
assert red > 1500, "no red floor tiles (%d px)" % red
colours = len(set(zip(v[0::3], v[1::3], v[2::3])))
assert colours > 500, "too few colours: %d" % colours
print("ok   picture: %d green ball px, %d red tile px, %d colours" % (green, red, colours))
EOF
then :; else bad "picture content"; fi

# sabotage: each broken copy must stop matching the twin
n=0
for edit in 's/\$depth - 1); 0\.25)/$depth - 1); 0.26)/' \
            's/then 0\.35 else 1/then 1 else 1/' \
            's/\[0\.85, 0\.2, 0\.15\]/[0.85, 0.25, 0.15]/' \
            's/vnorm(\[\$u, \$v - 0\.1, 1\.6\]); 2)/vnorm([$u, $v - 0.1, 1.6]); 1)/' \
            's/pow32(fmax/(fmax/'; do
  n=$((n + 1))
  sed "$edit" "$DIR/jqray.jq" > "$T/s$n.jq"
  if cmp -s "$DIR/jqray.jq" "$T/s$n.jq"; then bad "sabotage $n did not apply"; continue; fi
  jq -n -r --argjson w 41 --argjson h 29 -f "$T/s$n.jq" > "$T/s$n.ppm" 2>/dev/null
  if cmp -s "$T/s$n.ppm" "$T/b2.ppm"; then bad "sabotage $n not caught"; else ok "sabotage $n caught"; fi
done

if [ "$fail" = 0 ]; then echo PASS; exit 0; else echo FAIL; exit 1; fi
