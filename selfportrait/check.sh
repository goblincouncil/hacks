#!/bin/sh
# Exits 0 only if selfportrait.py really paints itself and the PNG decodes back to it.
set -u
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
ok() { echo "ok: $*"; }

# Second decoder, written separately from unpaint.py: all five filters,
# CRCs, chunk order, palette, and every block must be one solid index.
cat > "$T/strict.py" <<'EOF'
import sys, zlib
data = open(sys.argv[1], "rb").read()
if data[:8] != bytes([137, 80, 78, 71, 13, 10, 26, 10]):
    sys.exit("bad signature")
pos, chunks = 8, []
while pos < len(data):
    if pos + 12 > len(data):
        sys.exit("truncated chunk")
    n = int.from_bytes(data[pos:pos + 4], "big")
    t = data[pos + 4:pos + 8]
    d = data[pos + 8:pos + 8 + n]
    crc = data[pos + 8 + n:pos + 12 + n]
    if len(d) != n or len(crc) != 4:
        sys.exit("truncated chunk")
    if zlib.crc32(t + d).to_bytes(4, "big") != crc:
        sys.exit("bad CRC in %r" % t)
    chunks.append((t, d))
    pos += 12 + n
    if t == b"IEND":
        break
if pos != len(data):
    sys.exit("trailing bytes after IEND")
names = [t for t, _ in chunks]
if names[0] != b"IHDR" or names[-1] != b"IEND" or b"PLTE" not in names:
    sys.exit("bad chunk order")
ihdr = chunks[0][1]
w, h = int.from_bytes(ihdr[:4], "big"), int.from_bytes(ihdr[4:8], "big")
if tuple(ihdr[8:13]) != (8, 3, 0, 0, 0):
    sys.exit("not an 8-bit palette image")
pal = dict(chunks)[b"PLTE"]
if len(pal) != 768:
    sys.exit("palette must have 256 entries")
kw = kh = None
for t, d in chunks:
    if t == b"tEXt" and d.split(b"\0")[0] == b"scale":
        kw, kh = (int(v) for v in d.split(b"\0", 1)[1].split(b"x"))
if not kw or w % kw or h % kh:
    sys.exit("bad scale")
raw = zlib.decompress(b"".join(d for t, d in chunks if t == b"IDAT"))
if len(raw) != h * (w + 1):
    sys.exit("wrong IDAT size")
prev, img = bytes(w), []
for y in range(h):
    f, line = raw[y * (w + 1)], bytearray(raw[y * (w + 1) + 1:(y + 1) * (w + 1)])
    for x in range(w):
        a = line[x - 1] if x else 0
        b = prev[x]
        c = prev[x - 1] if x else 0
        if f == 1: line[x] = (line[x] + a) & 255
        elif f == 2: line[x] = (line[x] + b) & 255
        elif f == 3: line[x] = (line[x] + (a + b) // 2) & 255
        elif f == 4:
            p = a + b - c
            pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
            line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        elif f != 0: sys.exit("bad filter %d" % f)
    prev = bytes(line)
    img.append(prev)
out = []
for by in range(h // kh):
    cells = []
    for bx in range(w // kw):
        v = {img[by * kh + j][bx * kw + i] for j in range(kh) for i in range(kw)}
        if len(v) != 1:
            sys.exit("block %d,%d is not solid" % (bx, by))
        cells.append(v.pop())
    s = bytes(cells).rstrip(b"\0")
    if 0 in s:
        sys.exit("padding inside a line")
    out.append(s)
sys.stdout.buffer.write(b"\n".join(out) + b"\n")
EOF

for f in selfportrait.py selfportrait.png unpaint.py build.py body.txt; do
  test -s "$f" || fail "missing $f"
done
ok "files present"

python3 selfportrait.py > "$T/a.png" || fail "selfportrait.py crashed"
ok "program runs"

python3 -I "$T/strict.py" "$T/a.png" > "$T/strict.txt" || fail "strict decoder rejected the PNG"
cmp -s "$T/strict.txt" selfportrait.py || fail "strict decode differs from source"
ok "strict decoder reads back the exact source"

python3 unpaint.py "$T/a.png" > "$T/un.py" || fail "unpaint crashed"
cmp -s "$T/un.py" selfportrait.py || fail "unpaint differs from source"
ok "unpaint.py reads back the exact source"

python3 "$T/un.py" > "$T/b.png" || fail "decoded program crashed"
cmp -s "$T/a.png" "$T/b.png" || fail "decoded program draws a different PNG"
ok "fixed point: decoded program redraws the same PNG"

cmp -s "$T/a.png" selfportrait.png || fail "shipped selfportrait.png is stale"
ok "shipped selfportrait.png matches"

( cd "$T" && cp "$OLDPWD/body.txt" "$OLDPWD/build.py" . && python3 build.py ) || fail "build.py failed"
cmp -s "$T/selfportrait.py" selfportrait.py || fail "build.py output differs from selfportrait.py"
ok "build.py regenerates selfportrait.py"

# Sabotage: each broken copy must fail the round trip.
broken() {
  python3 "$1" > "$1.png" 2>/dev/null || return 0
  python3 -I "$T/strict.py" "$1.png" > "$1.txt" 2>/dev/null || return 0
  cmp -s "$1.txt" "$1" && return 1
  return 0
}
python3 - "$T" <<'EOF'
import sys
T = sys.argv[1]
src = open("selfportrait.py").read()
i = src.rindex("K=4")
open(T + "/s1.py", "w").write(src[:i] + "K=3" + src[i + 3:])
j = src.index("import")
open(T + "/s2.py", "w").write(src[:j] + "Import" + src[j + 6:])
EOF
broken "$T/s1.py" || fail "code-half edit not caught"
ok "sabotage caught: edit in the code half"
broken "$T/s2.py" || fail "string-half edit not caught"
ok "sabotage caught: edit in the string half"

python3 - "$T" <<'EOF'
import sys
T = sys.argv[1]
d = bytearray(open("selfportrait.png", "rb").read())
k = d.index(b"IDAT") + 20
d[k] ^= 0x40
open(T + "/flip.png", "wb").write(bytes(d))
EOF
if python3 -I "$T/strict.py" "$T/flip.png" > /dev/null 2>&1; then fail "flipped IDAT byte not caught"; fi
ok "sabotage caught: one flipped byte in IDAT"

echo PASS
