#!/bin/sh
# exits 0 only if sandpile.awk really settles piles correctly
cd "$(dirname "$0")" || exit 1
export PYTHONDONTWRITEBYTECODE=1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL $*"; exit 1; }

# run awk script $1 on N=$2 S=$3, compare to pile.py and checkpile.py
good() {
    awk -v N="$2" -v S="$3" -f "$1" > "$T/a.ppm" 2>/dev/null || return 1
    python3 pile.py "$2" "$3" > "$T/b.ppm" || return 1
    cmp -s "$T/a.ppm" "$T/b.ppm" || return 1
    python3 checkpile.py "$T/a.ppm" "$2" "$3" > /dev/null 2>&1 || return 1
}

for c in "0 1" "1 1" "3 2" "4 1" "5 3" "16 1" "100 2" "257 1" "1000 1" "2000 2" "3000 1"; do
    set -- $c
    good sandpile.awk "$1" "$2" || fail "N=$1 S=$2"
    echo "ok N=$1 S=$2 matches pile.py and checkpile.py"
done

for bad in "-v N=-1" "-v N=abc" "-v N=1.5" "-v S=0" "-v S=65" "-v S=x"; do
    if awk $bad -f sandpile.awk > "$T/o" 2>/dev/null; then fail "accepted $bad"; fi
    echo "ok refused $bad"
done

i=0
while IFS='|' read -r from to; do
    i=$((i + 1))
    sed "s/$from/$to/" sandpile.awk > "$T/s$i.awk"
    cmp -s sandpile.awk "$T/s$i.awk" && fail "sabotage $i did not apply"
    caught=0
    for c in "4 1" "16 1" "100 2" "1000 1"; do
        set -- $c
        good "$T/s$i.awk" "$1" "$2" || { caught=1; break; }
    done
    [ $caught = 1 ] || fail "sabotage $i ($from) not caught"
    echo "ok sabotage $i caught"
done <<'EOF'
h\[x, y\] -= 4 \* q|h[x, y] -= 3 * q
h\[x+1, y\] += q|h[x+1, y] += 2 * q
h\[x, y\] < 4|h[x, y] < 5
pal\[2\] = "240 200 60"|pal[2] = "240 200 61"
for (y = -E; y <= E; y++)|for (y = -E; y < E; y++)
h\[x, y-1\] += q|h[x, y+1] += q
EOF

echo PASS
