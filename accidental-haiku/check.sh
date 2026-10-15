#!/bin/sh
# exits 0 only if haiku.py really finds haiku and rejects non-haiku
d=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d) || exit 1
printf 'The old pond is still. A frog jumps in, and then splash, a sound of water.\n' > "$t/a.txt"
printf 'Hi.\n' > "$t/b.txt"
python3 "$d/haiku.py" "$t/a.txt" > "$t/out" 2>/dev/null || { echo FAIL: no haiku found; exit 1; }
printf 'The old pond is still\nA frog jumps in and then splash\na sound of water\n\n' > "$t/want"
cmp -s "$t/out" "$t/want" || { echo FAIL: wrong haiku; exit 1; }
python3 "$d/haiku.py" "$t/b.txt" >/dev/null 2>&1 && { echo FAIL: false positive; exit 1; }
python3 "$d/haiku.py" "$t/a.txt" 2>/dev/null | cmp -s - "$t/out" || { echo FAIL: not deterministic; exit 1; }
rm -rf "$t"
echo PASS
