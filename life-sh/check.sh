#!/bin/sh
# Exits 0 only if life.sh steps the grid correctly and rejects bad input.
set -u

here=$(cd "$(dirname "$0")" && pwd)
life="$here/life.sh"
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
fails=0

ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fails=$((fails + 1)); }

# keep only the rows of the last generation printed
last_gen() {
  awk '/^gen /{buf = ""; next} {buf = buf $0 "\n"} END {printf "%s", buf}' "$1"
}

# run GRID GENS NAME EXPECTED-FILE : last generation must equal EXPECTED-FILE
check_last() {
  if ! sh "$life" "$1" "$2" > "$tmp/out" 2>"$tmp/err"; then
    bad "$3: life.sh failed"; return
  fi
  last_gen "$tmp/out" > "$tmp/act"
  if cmp -s "$tmp/act" "$4"; then ok "$3"; else bad "$3"; fi
}

# blinker: vertical -> horizontal -> vertical
cat > "$tmp/blink0" <<'EOF'
.....
..#..
..#..
..#..
.....
EOF
cat > "$tmp/blink1" <<'EOF'
.....
.....
.###.
.....
.....
EOF
check_last "$tmp/blink0" 1 "blinker after 1 generation" "$tmp/blink1"
check_last "$tmp/blink0" 2 "blinker period 2" "$tmp/blink0"

# block is a still life
cat > "$tmp/block" <<'EOF'
......
..##..
..##..
......
EOF
check_last "$tmp/block" 5 "block still after 5 generations" "$tmp/block"

# glider in an 8x8 grid moves one cell down and right every 4 generations
cat > "$tmp/glider0" <<'EOF'
........
..#.....
...#....
.###....
........
........
........
........
EOF
cat > "$tmp/glider4" <<'EOF'
........
........
...#....
....#...
..###...
........
........
........
EOF
check_last "$tmp/glider0" 4 "glider moves by (1,1) after 4 generations" "$tmp/glider4"

# generation 0 is the input itself
sh "$life" "$tmp/blink0" 0 > "$tmp/out"
if [ "$(sed -n '2,$p' "$tmp/out")" = "$(cat "$tmp/blink0")" ]; then
  ok "generation 0 prints the input"
else
  bad "generation 0 prints the input"
fi

# every generation is printed: 0..2 gives three headers
sh "$life" "$tmp/blink0" 2 > "$tmp/out"
if [ "$(grep -c '^gen ' "$tmp/out")" -eq 3 ]; then ok "prints generations 0 through N"; else bad "prints generations 0 through N"; fi

# bad input is rejected with a non-zero exit
printf '.x.\n...\n' > "$tmp/badchar"
printf '...\n..\n' > "$tmp/ragged"
: > "$tmp/empty"
for f in badchar ragged empty; do
  if sh "$life" "$tmp/$f" 1 >/dev/null 2>&1; then bad "$f input accepted"; else ok "$f input rejected"; fi
done
for n in -1 abc 1.5; do
  if sh "$life" "$tmp/blink0" "$n" >/dev/null 2>&1; then bad "generations '$n' accepted"; else ok "generations '$n' rejected"; fi
done

# sabotaged copy: birth rule changed from 3 to 2 must be caught by the blinker
mkdir "$tmp/bad"
cp "$here/life.sh" "$tmp/bad/life.sh"
sed 's/nxt\[r, c\] = (n == 3)/nxt[r, c] = (n == 2)/' "$here/life.awk" > "$tmp/bad/life.awk"
if cmp -s "$here/life.awk" "$tmp/bad/life.awk"; then
  bad "sabotage edit did not apply"
else
  sh "$tmp/bad/life.sh" "$tmp/blink0" 1 > "$tmp/out" 2>/dev/null
  last_gen "$tmp/out" > "$tmp/act"
  if cmp -s "$tmp/act" "$tmp/blink1"; then bad "sabotaged rule not caught"; else ok "sabotaged rule caught"; fi
fi

if [ "$fails" -eq 0 ]; then
  echo "PASS"
  exit 0
fi
echo "FAIL: $fails check(s)"
exit 1
