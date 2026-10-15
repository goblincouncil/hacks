#!/bin/sh
# Passes only if selfie.xpm is both a real XPM image and a real C program,
# and the program paints exactly the pixels an image library reads from it.
set -eu
cd "$(dirname "$0")"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

# 1. It is an image: ImageMagick must decode it as a 24x24 XPM.
IM=magick; command -v magick >/dev/null 2>&1 || IM=convert
command -v "$IM" >/dev/null 2>&1 || fail "no ImageMagick found"
$IM selfie.xpm -alpha on txt:- > "$T/img.txt" 2>/dev/null || fail "ImageMagick cannot read selfie.xpm"
head -1 "$T/img.txt" | grep -q '^# ImageMagick pixel enumeration: 24,24,' || fail "not a 24x24 image"
echo "ok   image: ImageMagick reads a 24x24 picture"

# 2. It is a program: strict C compile with no warnings allowed.
cc -x c -std=c99 -Wall -Wextra -Werror -pedantic -o "$T/selfie" selfie.xpm || fail "does not compile as C"
echo "ok   program: compiles as C99 with -Wall -Wextra -Werror -pedantic"
"$T/selfie" > "$T/out.txt" || fail "program exited non-zero"
echo "ok   program: runs and exits 0"

# 3. The terminal picture and the decoded image agree, pixel for pixel.
python3 -I - "$T/img.txt" "$T/out.txt" <<'EOF' || fail "terminal output does not match the image"
import re, sys
img = {}
for line in open(sys.argv[1]).read().splitlines()[1:]:
    m = re.match(r'(\d+),(\d+): \((\d+),(\d+),(\d+),(\d+)\)', line)
    x, y, r, g, b, a = map(int, m.groups())
    img[x, y] = None if a == 0 else (r, g, b)

out = open(sys.argv[2], encoding='utf-8').read()
rows = out.split('\n')
assert rows[-1] == '', 'output must end with a newline'
rows = rows[:-1]
assert len(rows) == 12, 'expected 12 text rows, got %d' % len(rows)
tok = re.compile(r'\033\[([0-9;]*)m|(.)', re.S)
seen = {}
for ty, row in enumerate(rows):
    fg = bg = None
    tx = 0
    for m in tok.finditer(row):
        if m.group(1) is not None:
            p = [int(v) for v in m.group(1).split(';')]
            if p == [0]: fg = bg = None
            elif p == [39]: fg = None
            elif p == [49]: bg = None
            elif p[:2] == [38, 2]: fg = tuple(p[2:5])
            elif p[:2] == [48, 2]: bg = tuple(p[2:5])
            else: raise AssertionError('unknown escape %r' % p)
            continue
        ch = m.group(2)
        if ch == ' ': top = bot = None
        elif ch == '\u2580': top, bot = fg, bg
        elif ch == '\u2584': top, bot = bg, fg
        else: raise AssertionError('unexpected glyph %r' % ch)
        seen[tx, 2 * ty], seen[tx, 2 * ty + 1] = top, bot
        tx += 1
    assert tx == 24, 'row %d has %d cells' % (ty, tx)
bad = [k for k in img if img[k] != seen.get(k, 'missing')]
assert not bad, '%d pixels differ, first %r: image %r, terminal %r' % (
    len(bad), bad[0], img[bad[0]], seen.get(bad[0]))
colours = {v for v in img.values() if v}
assert len(colours) >= 8, 'too few colours: %d' % len(colours)
print('ok   match: all %d pixels agree, %d colours plus transparency' % (len(img), len(colours)))
EOF

# 4. The test can fail: change one pixel in the image and the output must change too.
sed '/^"\.\.\.\.gggggggggggggggg\.\.\.\.",$/{s/gggg\.\.\.\."/gggy...."/;}' selfie.xpm > "$T/edit.c"
cmp -s selfie.xpm "$T/edit.c" && fail "sabotage edit did not apply"
cc -x c -o "$T/edit" "$T/edit.c" && "$T/edit" > "$T/edit.txt"
cmp -s "$T/out.txt" "$T/edit.txt" && fail "program ignores its own pixels"
echo "ok   honest: a one-pixel edit to the picture changes what the program paints"
echo PASS
