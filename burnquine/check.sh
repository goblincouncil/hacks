#!/bin/sh
# Passes only if burnquine.py burns its own text and ends as an exact copy of itself.
set -e
cd "$(cd "$(dirname "$0")" && pwd)"
command -v python3 >/dev/null || { echo "FAIL: python3 not found"; exit 1; }
test -s burnquine.py || { echo "FAIL: burnquine.py missing"; exit 1; }

# 1. the shipped file is what gen.py builds from body.py
python3 gen.py > /tmp/burnquine.regen.$$
cmp -s /tmp/burnquine.regen.$$ burnquine.py || { rm -f /tmp/burnquine.regen.$$; echo "FAIL: burnquine.py is stale, run python3 gen.py > burnquine.py"; exit 1; }
rm -f /tmp/burnquine.regen.$$

# 2. run it twice with no delay, then inspect the frames
BURN_DELAY=0 python3 burnquine.py > /tmp/burnquine.out1.$$
BURN_DELAY=0 python3 burnquine.py > /tmp/burnquine.out2.$$
python3 - /tmp/burnquine.out1.$$ /tmp/burnquine.out2.$$ <<'EOF'
import re, sys
src = open('burnquine.py').read()
a = open(sys.argv[1]).read()
b = open(sys.argv[2]).read()
fail = []
if a != b:
    fail.append('output differs between runs')
# the last screen is the exact source, after a clear
if not a.endswith('\x1b[2J\x1b[H' + src):
    fail.append('last screen is not an exact copy of burnquine.py')
frames = a.split('\x1b[H')[1:-1]
if len(frames) < 60:
    fail.append('only %d fire frames' % len(frames))
# every flame glyph sits where the source text puts it
W, H = 78, 24
t = src.replace('\n', ' ')
t = (t * (W * H // len(t) + 1))[:W * H]
ansi = re.compile(r'\x1b\[[0-9;?]*[A-Za-z]')
lit = 0; colours = set(); bad = 0
for fr in frames:
    colours.update(re.findall(r'\x1b\[38;5;(\d+)m', fr))
    rows = ansi.sub('', fr).split('\n')
    if len(rows) != H or any(len(r) != W for r in rows):
        bad += 1; continue
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c != ' ':
                lit += 1
                if c != t[y * W + x]:
                    bad += 1
if bad:
    fail.append('%d frames or glyphs do not match the source text' % bad)
mid = ansi.sub('', frames[len(frames) // 3])
if sum(c != ' ' for c in mid) < 300:
    fail.append('fire is too small at frame %d' % (len(frames) // 3))
end = ansi.sub('', frames[-1])
if sum(c != ' ' for c in end) > 40:
    fail.append('fire never dies down')
if len(colours) < 8:
    fail.append('only %d colours' % len(colours))
if fail:
    print('FAIL: ' + '; '.join(fail)); sys.exit(1)
print('ok: %d frames, %d burning glyphs, %d colours, %d-byte quine' % (len(frames), lit, len(colours), len(src)))
EOF
rc=$?
rm -f /tmp/burnquine.out1.$$ /tmp/burnquine.out2.$$
[ $rc -eq 0 ] && echo PASS
exit $rc
