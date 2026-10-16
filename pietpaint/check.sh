#!/bin/sh
# check.sh: exit 0 only if paint.py + piet.py round-trip text, the
# interpreter obeys known Piet rules, and sabotaged copies are caught.
cd "$(dirname "$0")" || exit 1
export PYTHONDONTWRITEBYTECODE=1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }

# 1. round trips: painted text runs back to the same bytes, and halts
python3 - "$T" <<'EOF' || fail=1
import os, random, subprocess, sys
t = sys.argv[1]
cases = ["goblincouncil", "", "a", "Hello, World!", "x\ny\x01z", "~ 0 @",
         "\x10\x20\x7f", "".join(chr(c) for c in range(1, 128))]
rnd = random.Random(14)
for _ in range(20):
    cases.append("".join(chr(rnd.randrange(1, 128))
                         for _ in range(rnd.randrange(1, 40))))
bad = 0
for i, s in enumerate(cases):
    img = subprocess.run(["python3", "paint.py", s], capture_output=True,
                         check=True).stdout
    p = os.path.join(t, "c%d.ppm" % i)
    open(p, "wb").write(img)
    try:
        out = subprocess.run(["python3", "piet.py", "-n", "100000", p],
                             capture_output=True, timeout=30)
        good = out.returncode == 0 and out.stdout == s.encode()
        got = out.stdout[:60]
    except subprocess.TimeoutExpired:
        good, got = False, b"(timeout)"
    if not good:
        bad += 1
        print("FAIL round trip %r -> %r" % (s[:30], got))
print(("ok" if not bad else "FAIL") + "   round trip %d of %d texts"
      % (len(cases) - bad, len(cases)))
sys.exit(1 if bad else 0)
EOF

# 2. codel size: a painting blown up 7x is still the same program
python3 paint.py goblincouncil > "$T/g.ppm"
python3 frame.py "$T/g.ppm" 7 > "$T/g7.ppm"
[ "$(timeout 60 python3 piet.py -c 7 -n 100000 "$T/g7.ppm")" = goblincouncil ] \
    && ok "7x blown-up painting with -c 7" || bad "codel size 7"

# 3. the painting really is colours: only the 20 Piet colours appear
python3 - "$T/g.ppm" <<'EOF' && ok "only Piet colours used" || bad "colours"
import sys
d = open(sys.argv[1], "rb").read().split(b"\n", 3)[3]
legal = {bytes.fromhex(h) for h in
 "ffc0c0 ff0000 c00000 ffffc0 ffff00 c0c000 c0ffc0 00ff00 00c000 c0ffff "
 "00ffff 00c0c0 c0c0ff 0000ff 0000c0 ffc0ff ff00ff c000c0 ffffff 000000"
 .split()}
px = {d[i:i+3] for i in range(0, len(d), 3)}
sys.exit(0 if px <= legal and len(px) > 4 else 1)
EOF

# 4. hand-made programs pin the interpreter to the Piet spec. The op
# table is written out again here, so these tests do not trust piet.py.
# Each program is also saved for the sabotage runs below.
python3 - "$T" <<'EOF' || fail=1
import os, subprocess, sys
t = sys.argv[1]
HEX = [["ffc0c0", "ff0000", "c00000"], ["ffffc0", "ffff00", "c0c000"],
       ["c0ffc0", "00ff00", "00c000"], ["c0ffff", "00ffff", "00c0c0"],
       ["c0c0ff", "0000ff", "0000c0"], ["ffc0ff", "ff00ff", "c000c0"]]
COL = [[tuple(bytes.fromhex(x)) for x in r] for r in HEX]
W, K = (255, 255, 255), (0, 0, 0)
# (hue steps, lightness steps) for each command, from the Piet spec
STEP = {"push": (0, 1), "pop": (0, 2), "add": (1, 0), "sub": (1, 1),
        "mul": (1, 2), "div": (2, 0), "mod": (2, 1), "not": (2, 2),
        "greater": (3, 0), "pointer": (3, 1), "switch": (3, 2),
        "dup": (4, 0), "roll": (4, 1), "in_num": (4, 2),
        "in_char": (5, 0), "out_num": (5, 1), "out_char": (5, 2)}
def nxt(c, op):
    h, l = c
    dh, dl = STEP[op]
    return (h + dh) % 6, (l + dl) % 3
def px(c):
    return COL[c[0]][c[1]]
def line(row):
    """one stripe; the last colour becomes an L hooked under its
    neighbour so the program halts"""
    i = len(row) - 2
    trap = [K] * len(row)
    trap[i] = trap[i - 1] = row[i]
    return [row, trap, [K] * len(row)]
def ladder(steps):
    """steps: (op, width of the block that op leaves). A push reads
    that width, since everything under the stripe is black."""
    c, row = (0, 1), []
    for op, w in steps:
        row += [px(c)] * w
        c = nxt(c, op)
    return line(row + [px(c), K])
R = (0, 1)
DR = nxt(R, "push")
X = nxt(DR, "out_num")
tests = [
 ("push, out_num", ladder([("push", 3), ("out_num", 1)]), b"", b"3"),
 ("in_char, out_char", ladder([("in_char", 1), ("out_char", 1)]),
  b"Q", b"Q"),
 ("push, push, sub order", ladder([("push", 5), ("push", 2), ("sub", 1),
                                   ("out_num", 1)]), b"", b"3"),
 ("dup, mul", ladder([("push", 3), ("dup", 1), ("mul", 1),
                      ("out_num", 1)]), b"", b"9"),
 ("not, push, div", ladder([("push", 1), ("not", 1), ("push", 1),
                            ("div", 1), ("out_num", 1)]), b"", b"0"),
 # R R DR, white gap (no op), DR again (a new block), then out_num
 ("white is a no-op", line([px(R), px(R), px(DR), W, W, px(DR), px(X), K]),
  b"", b"2"),
 # DR has black on its right, so dp turns down into X: out_num
 ("turn at a wall", [[px(R), px(R), px(DR), K, px(X)],
                     [K, K, px(X), px(X), px(X)],
                     [K, K, K, K, K]], b"", b"2"),
]
def save(path, rows):
    h, w = len(rows), len(rows[0])
    open(path, "wb").write(b"P6\n%d %d\n255\n" % (w, h) +
                           bytes(c for r in rows for p in r for c in p))
bad = 0
for n, (name, rows, inp, want) in enumerate(tests):
    base = os.path.join(t, "spec%d" % n)
    save(base + ".ppm", rows)
    open(base + ".in", "wb").write(inp)
    open(base + ".want", "wb").write(want)
    try:
        r = subprocess.run(["python3", "piet.py", "-n", "1000",
                            base + ".ppm"], input=inp, capture_output=True,
                           timeout=20)
        got = r.stdout if r.returncode == 0 else b"(rc %d)" % r.returncode
    except subprocess.TimeoutExpired:
        got = b"(timeout)"
    if got == want:
        print("ok   spec: " + name)
    else:
        bad += 1
        print("FAIL spec: %s want %r got %r" % (name, want, got[:40]))
sys.exit(1 if bad else 0)
EOF

# 5. sabotage: a broken interpreter must fail the round trip or a spec test
python3 paint.py "goblincouncil" > "$T/s.ppm"
for sab in "s/(h1 - h0) % 6/(h0 - h1) % 6/" \
           "s/(l1 - l0) % 3/(l1 - l0 + 1) % 3/" \
           "s/s.append(size)/s.append(size + 1)/" \
           "s/far = max(/far = min(/"; do
    sed "$sab" piet.py > "$T/sab.py"
    cmp -s piet.py "$T/sab.py" && { bad "sabotage did not apply: $sab"; continue; }
    caught=0
    out=$(cd "$T" && timeout 20 python3 sab.py -n 20000 s.ppm 2>/dev/null | head -c 100)
    [ "$out" != goblincouncil ] && caught=1
    for p in "$T"/spec*.ppm; do
        b=${p%.ppm}
        got=$(timeout 20 python3 "$T/sab.py" -n 1000 "$p" < "$b.in" 2>/dev/null | head -c 100)
        [ "$got" != "$(cat "$b.want")" ] && caught=1
    done
    [ $caught = 1 ] && ok "sabotage caught: $sab" \
        || bad "sabotage not caught: $sab"
done

[ $fail = 0 ] && echo PASS || echo FAIL
exit $fail
