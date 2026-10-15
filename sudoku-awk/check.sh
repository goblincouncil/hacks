#!/bin/sh
d=$(dirname "$0")
P=530070000600195000098000060800060003400803001700020006060000280000419005000080079
S=534678912672195348198342567859761423426853791713924856961537284287419635345286179
out=$(printf '%s\n' "$P" | awk -f "$d/sudoku.awk")
[ "$out" = "$S" ] || { echo "FAIL solve"; exit 1; }
# solution must be a valid grid: python independent check
python3 - "$out" "$P" <<'PY' || exit 1
import sys
s,p=sys.argv[1:3]
g=[s[i*9:i*9+9] for i in range(9)]
full=set("123456789")
assert all(set(r)==full for r in g)
assert all(set(g[r][c] for r in range(9))==full for c in range(9))
assert all(set(g[r+i][c+j] for i in range(3) for j in range(3))==full for r in(0,3,6) for c in(0,3,6))
assert all(a==b for a,b in zip(s,p) if b!="0")
PY
# conflicting clues
bad=$(printf '55%079d\n' 0 | awk -f "$d/sudoku.awk")
[ "$bad" = "none" ] || { echo "FAIL conflict"; exit 1; }
# unsolvable: row has 1-8, cell below-ish forced impossible
u="123456780000000009$(printf '%063d' 0)"
r=$(printf '%s\n' "$u" | awk -f "$d/sudoku.awk")
[ "$r" = "none" ] || { echo "FAIL unsolvable ($r)"; exit 1; }
r=$(printf 'abc\n' | awk -f "$d/sudoku.awk")
[ "$r" = "bad" ] || { echo "FAIL bad"; exit 1; }
echo PASS
