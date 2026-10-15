#!/bin/sh
# exits 0 only if specter paints a picture into a WAV and reads the same picture back out
D=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export PYTHONDONTWRITEBYTECODE=1
fail() { echo "FAIL: $*"; exit 1; }

python3 "$D/specter.py" paint "$T/a.wav" || fail "paint crashed"
python3 "$D/specter.py" paint "$T/b.wav" || fail "second paint crashed"
cmp -s "$T/a.wav" "$T/b.wav" || fail "two paints differ"
echo "ok: paint is deterministic"

python3 "$D/specter.py" picture > "$T/want.txt" || fail "picture crashed"
python3 "$D/specter.py" read "$T/a.wav" "$T/a.pgm" > "$T/got.txt" || fail "read crashed"
cmp -s "$T/want.txt" "$T/got.txt" || { diff "$T/want.txt" "$T/got.txt" | head; fail "picture read from the WAV differs from the painted one"; }
echo "ok: picture survives the round trip through sound"

python3 - "$D/specter.py" "$T" <<'EOF' || fail "python checks"
import sys, wave, struct, math, importlib.util
spec = importlib.util.spec_from_file_location("specter", sys.argv[1])
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
T = sys.argv[2]
def bad(m): print("FAIL:", m); sys.exit(1)

with wave.open(T + "/a.wav") as w:
    if (w.getnchannels(), w.getsampwidth(), w.getframerate()) != (1, 2, S.RATE): bad("wrong wav format")
    if w.getnframes() != S.COLS * S.COL: bad("wrong wav length")
    d = w.readframes(w.getnframes())
sm = struct.unpack("<%dh" % (len(d) // 2), d)
pk = max(abs(x) for x in sm)
if pk < 2000: bad("sound is nearly silent, peak %d" % pk)
if pk >= 32767: bad("sound clips")
print("ok: 16-bit mono %d Hz, %.1f s, peak %d" % (S.RATE, len(sm) / S.RATE, pk))

want = S.picture(); got = S.listen(list(sm))
err = max(abs(want[r][c] - got[r][c]) for r in range(S.ROWS) for c in range(S.COLS))
if err > 0.01: bad("pixel error %.4f" % err)
print("ok: largest pixel error %.6f" % err)

shades = {round(want[r][c], 1) for r in range(S.ROWS) for c in range(36) if want[r][c] > 0}
if len(shades) < 8: bad("ball has only %d shades" % len(shades))
title = sum(1 for r in range(S.ROWS) for c in range(38, S.COLS) if want[r][c] == 1.0)
if title < 300: bad("title missing (%d lit pixels)" % title)
print("ok: ball has %d shades, title has %d lit pixels" % (len(shades), title))

if any(v > 0.01 for row in S.listen([0] * (S.COL * 4)) for v in row): bad("silence reads as a picture")
print("ok: silence reads blank")

tone = [int(10000 * math.sin(2 * math.pi * 2000 * n / S.RATE)) for n in range(S.COL * 3)]
img = S.listen(tone)
lit = [r for r in range(S.ROWS) if img[r][1] > 0.05]
if lit != [S.ROWS - 1 - (2000 - S.BASE) // S.STEP]: bad("a 2000 Hz tone lit rows %s" % lit)
print("ok: a 2000 Hz tone lights exactly row %d" % lit[0])

with open(T + "/a.pgm", "rb") as f:
    if not f.read(3) == b"P5\n": bad("pgm header")
print("ok: pgm written")
EOF
echo PASS
