#!/bin/sh
set -e
cd "$(dirname "$0")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

python3 beeper.py compile poem.txt "$tmp/tune.bas"
python3 beeper.py play "$tmp/tune.bas" "$tmp/tune.wav"

grep -qF "$(head -n 1 poem.txt)" "$tmp/tune.bas"

python3 - "$tmp/tune.bas" "$tmp/tune.wav" <<'EOF'
import sys, wave
bas, wav = sys.argv[1], sys.argv[2]
lines = open(bas).read().splitlines()
assert lines[-1].split()[1] == "END", "listing does not end in END"
notes = [l for l in lines if " SOUND " in l]
assert len(notes) > 20, "too few notes: %d" % len(notes)
w = wave.open(wav)
assert w.getnchannels() == 1, "not mono"
assert w.getsampwidth() == 2, "not 16-bit"
assert w.getframerate() == 8000, "wrong rate"
assert w.getnframes() > 8000, "clip under one second"
frames = w.readframes(w.getnframes())
assert len(set(frames)) > 2, "flat signal"
print("ok: %d notes, %d frames" % (len(notes), w.getnframes()))
EOF
