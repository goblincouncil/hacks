#!/bin/sh
# Exits 0 only if roman.sed matches a Python reference, and a sabotaged copy is caught.
cd "$(dirname "$0")" || exit 1
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

python3 -I - "$tmp/in" "$tmp/exp" <<'EOF' || exit 1
import random, sys
VALS = [(1000,'M'),(900,'CM'),(500,'D'),(400,'CD'),(100,'C'),(90,'XC'),(50,'L'),(40,'XL'),(10,'X'),(9,'IX'),(5,'V'),(4,'IV'),(1,'I')]
def to_roman(n):
    out = ''
    for v, s in VALS:
        while n >= v:
            out += s
            n -= v
    return out
pairs = [(a, b) for a in range(1, 61) for b in range(1, 61)]
rng = random.Random(14)
pairs += [(rng.randint(1, 3999), rng.randint(1, 3999)) for _ in range(3000)]
lines = []
exp = []
for a, b in pairs:
    lines.append(to_roman(a) + ' ' + to_roman(b))
    exp.append(to_roman(a + b))
# invalid input must print ?
for bad in ['', ' I', 'I ', 'I  I', 'IIII I', 'VX I', 'I+I', 'XIV', 'MMMM I']:
    lines.append(bad)
    exp.append('?')
open(sys.argv[1], 'w').write('\n'.join(lines) + '\n')
open(sys.argv[2], 'w').write('\n'.join(exp) + '\n')
print(len(lines))
EOF

sed -E -f roman.sed "$tmp/in" > "$tmp/out" 2>"$tmp/err" || { echo "sed failed"; cat "$tmp/err"; exit 1; }
if ! cmp -s "$tmp/exp" "$tmp/out"; then
    echo "mismatch with reference"
    exit 1
fi
n=$(wc -l < "$tmp/out")
echo "matched $n lines"

# sabotage: drop one fold rule, the check must catch it
grep -v 'DCCCC/CM' roman.sed > "$tmp/bad.sed"
sed -E -f "$tmp/bad.sed" "$tmp/in" > "$tmp/bad.out" 2>/dev/null
if cmp -s "$tmp/exp" "$tmp/bad.out"; then
    echo "sabotaged copy was not caught"
    exit 1
fi
echo "sabotage caught"
echo PASS
exit 0
