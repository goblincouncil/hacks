#!/bin/sh
# check.sh: exits 0 only if donut.awk really draws the spinning torus.
set -u
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
ok() { echo "ok: $*"; }

[ -f donut.awk ] && [ -f ref.py ] || fail "missing donut.awk or ref.py"

# 1. byte-for-byte against the independent Python reference
awk -v frames=60 -f donut.awk > "$T/a" || fail "awk exited nonzero"
python3 ref.py 60 > "$T/r" || fail "ref.py exited nonzero"
cmp -s "$T/a" "$T/r" || fail "awk frames differ from ref.py"
ok "60 frames match ref.py byte for byte"

# 2. shape: 60 frames of 22 rows, no row wider than 80, frames all differ
python3 - "$T/a" <<'PY' || fail "shape checks"
import sys
lines = open(sys.argv[1]).read().split("\n")
assert lines[-1] == "" and lines[-2] == "--", "output must end with --"
frames, cur = [], []
for ln in lines[:-1]:
    if ln == "--":
        frames.append("".join(r + "\n" for r in cur)); cur = []
    else:
        cur.append(ln)
assert len(frames) == 60, len(frames)
for f in frames:
    rows = f.split("\n")[:-1]
    assert len(rows) == 22, len(rows)
    assert all(len(r) <= 80 for r in rows)
assert len(set(frames)) == 60, "some frames repeat"
used = set("".join(frames)) - set(" \n")
assert used == set(".,-~:;=!*#$@"), sorted(used)
# frame 0 must be a ring: ink above, below, left and right of an empty centre
rows = [r.ljust(80) for r in frames[0].split("\n")[:-1]]
assert rows[11][40] == " ", "no hole in the middle"
assert rows[11][22] != " " and rows[11][58] != " ", "no ink beside the hole"
assert rows[3][40] != " " and rows[18][40] != " ", "no ink above/below the hole"
PY
ok "60 frames, 22 rows, width <= 80, all different, all 12 shades used"
ok "frame 0 is a ring with a hole"

# 3. animation mode emits clear and home escapes and the same picture
awk -v play=1 -v frames=2 -f donut.awk > "$T/p" || fail "play mode"
grep -q "$(printf '\033')\[2J" "$T/p" || fail "no clear-screen escape"
[ "$(grep -c "$(printf '\033')\[H" "$T/p")" -eq 2 ] || fail "want 2 home escapes"
ok "play mode clears once and homes the cursor each frame"

# 4. sabotaged copies must be caught by the reference comparison
head -n 23 "$T/r" > "$T/r1"; python3 ref.py 8 > "$T/r8"
sab() {
    sed "$1" donut.awk > "$T/s.awk"
    cmp -s donut.awk "$T/s.awk" && fail "sabotage '$2' did not change the script"
    awk -v frames=8 -f "$T/s.awk" > "$T/s" 2>/dev/null
    cmp -s "$T/s" "$T/r8" && fail "sabotage '$2' went unnoticed"
    ok "sabotage caught: $2"
}
sab 's/D > z\[o\] + 0/D >= z[o] + 0/' "z-buffer ties"
sab 's/ramp = ".,-~:;=!\*#\$@"/ramp = "@$#*!=;:~-,."/' "reversed shade ramp"
sab 's/h = d + 2/h = d + 1/' "fat tube, thin hole"
sab 's/B = k \* 0.02/B = 0/' "no second spin axis"

echo PASS
