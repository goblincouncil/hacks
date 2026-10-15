#!/bin/sh
# Exits 0 only if the renderer writes correct WAV files and logs.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
beeper() { python3 -I "$here/beeper.py" "$@"; }

# 1. the shipped poem renders; WAV length and log lines match the score
beeper "$here/poem.txt" "$tmp/poem.wav" > "$tmp/poem.log" || fail 'poem.txt did not render'
python3 -I - "$here/poem.txt" "$tmp/poem.wav" "$tmp/poem.log" <<'EOF' || fail 'poem checks'
import re, sys, wave
poem, wav_path, log_path = sys.argv[1:4]
tempo, frames, notes = 120.0, 0, 0
for raw in open(poem):
    code = raw.split(';', 1)[0].split()
    if not code:
        continue
    if code[0] == 'tempo':
        tempo = float(code[1])
        continue
    assert len(code) == 3, code
    beat = 60.0 / tempo
    frames += round(float(code[1]) * beat * 8000) + round(float(code[2]) * beat * 8000)
    notes += 1
w = wave.open(wav_path)
assert (w.getnchannels(), w.getsampwidth(), w.getframerate()) == (1, 1, 8000), 'format'
assert w.getnframes() == frames, (w.getnframes(), frames)
log_lines = open(log_path).read().splitlines()
assert len([l for l in log_lines if re.match(r' *[0-9]+ ', l)]) == notes, 'log count'
assert any('a frog sits' in l for l in log_lines), 'verse missing from log'
assert notes >= 10, notes
print(f'poem ok: {notes} notes, {frames} frames')
EOF

# 2. A4 for one second is 440 Hz: about 880 level changes in the sample stream
printf 'tempo 60\nA4 1 0\n' > "$tmp/a4.txt"
beeper "$tmp/a4.txt" "$tmp/a4.wav" > /dev/null || fail 'a4 did not render'
python3 -I - "$tmp/a4.wav" <<'EOF' || fail 'a4 frequency'
import sys, wave
w = wave.open(sys.argv[1])
data = w.readframes(w.getnframes())
changes = sum(1 for a, b in zip(data, data[1:]) if (a >= 128) != (b >= 128))
assert w.getnframes() == 8000, w.getnframes()
assert 870 <= changes <= 890, changes
EOF

# 3. a silent note plus a rest is pure silence of the right length
printf 'tempo 60\n- 0.5 0.5\n' > "$tmp/rest.txt"
beeper "$tmp/rest.txt" "$tmp/rest.wav" > /dev/null || fail 'rest did not render'
python3 -I -c '
import sys, wave
w = wave.open(sys.argv[1])
d = w.readframes(w.getnframes())
assert w.getnframes() == 8000 and set(d) == {128}, "not silent"
' "$tmp/rest.wav" || fail 'silence'

# 4. a bad note is refused, and the error names it
printf 'tempo 60\nH9 1 0\n' > "$tmp/bad.txt"
if beeper "$tmp/bad.txt" "$tmp/bad.wav" > /dev/null 2> "$tmp/err"; then fail 'bad note accepted'; fi
grep -q 'H9' "$tmp/err" || fail 'error does not name the bad note'

# 5. same input, same bytes
beeper "$here/poem.txt" "$tmp/again.wav" > /dev/null
cmp -s "$tmp/poem.wav" "$tmp/again.wav" || fail 'output not deterministic'

echo 'PASS'
