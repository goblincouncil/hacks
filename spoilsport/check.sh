#!/bin/sh
# Exits 0 only if spoilsport.sed really never loses at tic-tac-toe.
cd "$(dirname "$0")" || exit 1
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

# 1. the shipped script is what the generator writes
python3 gen.py > "$tmp/fresh.sed"
if cmp -s "$tmp/fresh.sed" spoilsport.sed; then ok "spoilsport.sed matches gen.py"; else bad "spoilsport.sed differs from gen.py output"; fi

# 2. the whole game tree, human opening and spoilsport opening
if python3 referee.py spoilsport.sed > "$tmp/ref.out"; then
    ok "every human game played, none lost ($(sed -n 's/^games played: //p' "$tmp/ref.out") games)"
else
    bad "referee: $(head -5 "$tmp/ref.out" | tr '\n' ' ')"
fi

# 3. same tree under --posix, so no GNU-only regex sneaks in
if SED='sed --posix' python3 referee.py spoilsport.sed > /dev/null; then ok "passes under sed --posix"; else bad "fails under sed --posix"; fi

# 4. fixed answers
while read -r in want; do
    got=$(printf '%s\n' "$in" | sed -f spoilsport.sed)
    if [ "$got" = "$want" ]; then ok "$in -> $want"; else bad "$in -> '$got', wanted '$want'"; fi
done <<'EOF'
......... ....O....
X........ X...O....
X...O...X XO..O...X
XX.O..... XXOO.....
OO.XX.... OOOXX.... spoilsport wins
EOF

# 5. bad input is refused, not played
while read -r in want; do
    got=$(printf '%s\n' "$in" | sed -f spoilsport.sed)
    if [ "$got" = "$want" ]; then ok "refuses $in"; else bad "$in -> '$got', wanted '$want'"; fi
done <<'EOF'
abc ? not a board
X.......O. ? not a board
XX....... ? not my turn
O........ ? not my turn
XXX.OO... ? you already won
OOOXX.X.. ? I already won
XOXXOOOXX ? board full
EOF

# 6. sabotage: each broken copy must be caught by the referee
sabotage() {
    name=$1; shift
    "$@" spoilsport.sed > "$tmp/broken.sed"
    if cmp -s "$tmp/broken.sed" spoilsport.sed; then bad "sabotage '$name' changed nothing"; return; fi
    if python3 referee.py "$tmp/broken.sed" > /dev/null 2>&1; then bad "sabotage '$name' not caught"; else ok "sabotage caught: $name"; fi
}
sabotage "no blocking" sed '/^# --- 2. block/,/^# --- 3/{/^s/d;}'
sabotage "no fork defence" sed '/^# --- 5. take/,/^# --- 6/{/^s/d;}'
sabotage "no side attack" sed '/^# --- 4. you hold/,/^# --- 5/{/^s/d;}'
sabotage "corner before centre" sed '/^# --- 6. centre/,/^# --- 7/{/^s/d;}'
sabotage "plays X not O" sed 's/\\1O\\2/\\1X\\2/'

if [ $fail = 0 ]; then echo PASS; else echo FAIL; fi
exit $fail
