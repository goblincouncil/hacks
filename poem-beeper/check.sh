#!/bin/sh
# Exits 0 only if the beeper renders the poem deterministically into a
# valid 8-bit mono square-wave WAV whose log quotes every poem line.
set -e
cd "$(dirname "$0")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

python3 beeper.py poem.txt "$tmp/a.wav" "$tmp/a.log"
python3 beeper.py poem.txt "$tmp/b.wav" "$tmp/b.log"
cmp "$tmp/a.wav" "$tmp/b.wav"
cmp "$tmp/a.log" "$tmp/b.log"

python3 - "$tmp/a.wav" poem.txt "$tmp/a.log" <<'EOF'
import sys, wave
path, poem, log = sys.argv[1:4]
with wave.open(path, 'rb') as w:
    assert w.getnchannels() == 1, 'not mono'
    assert w.getsampwidth() == 1, 'not 8-bit'
    assert w.getframerate() == 22050, 'wrong rate'
    n = w.getnframes()
    frames = w.readframes(n)
assert n > 22050, 'too short: %d frames' % n
levels = set(frames)
assert {224, 32} <= levels, 'not a two-level square wave'
assert levels <= {224, 32, 128}, 'unexpected sample levels'
text = open(poem, encoding='utf-8').read()
logtxt = open(log, encoding='utf-8').read()
for line in text.strip().splitlines():
    assert line.strip() in logtxt, 'log lost a poem line: ' + line
notes = [l for l in logtxt.splitlines() if ' Hz ' in l]
words = len(text.split())
assert len(notes) >= words - 2, 'expected about one note per word, got %d' % len(notes)
print('ok: %d frames, %.2fs, %d notes' % (n, n / 22050, len(notes)))
EOF
