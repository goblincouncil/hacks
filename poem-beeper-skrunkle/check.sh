#!/bin/sh
# exits 0 only if beep really compiles a poem to a valid square-wave WAV
set -e
cd "$(dirname "$0")"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

python3 -I beep.py examples/poem.txt "$T/a.wav" > "$T/log.txt"
python3 -I beep.py examples/poem.txt "$T/b.wav" > /dev/null
cmp -s "$T/a.wav" "$T/b.wav"
grep -q 'moon' "$T/log.txt"

python3 -I - "$T/a.wav" <<'EOF'
import sys, wave
w = wave.open(sys.argv[1], 'rb')
assert w.getnchannels() == 1 and w.getsampwidth() == 2 and w.getframerate() == 22050
s = memoryview(w.readframes(w.getnframes())).cast('h')
assert len(s) > 22050, len(s)
vals = set(s)
assert 9000 in vals and -9000 in vals, 'not a square wave'
assert sum(1 for x in s if x) > 0.5 * len(s), 'too much silence'
print('wav ok', len(s), 'samples')
EOF

printf '10 GOTO 20\n' > "$T/bad.txt"
if python3 -I beep.py "$T/bad.txt" "$T/bad.wav" 2> /dev/null; then
    echo 'bad statement compiled' >&2
    exit 1
fi
echo 'check ok'
