#!/bin/sh
d=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
cat > "$t/v.py" <<'PY'
import sys
def ok(txt, w, h):
    L = txt.split("\n")
    if L and L[-1] == "": L.pop()
    if len(L) != 2*h+1 or any(len(r) != 2*w+1 for r in L): return False
    if any(c not in "# " for r in L for c in r): return False
    if any(c != "#" for c in L[0]+L[-1]) or any(r[0] != "#" or r[-1] != "#" for r in L): return False
    for y in range(h+1):
        for x in range(w+1):
            if L[2*y][2*x] != "#": return False   # pillars stay solid
    cells = [(x,y) for y in range(h) for x in range(w)]
    edges = sum(1 for y in range(h) for x in range(w)
                for ex,ey in ((x+1,y),(x,y+1)) if ex<w and ey<h and L[y+ey+1][x+ex+1]==" ")
    if edges != len(cells)-1: return False
    seen = {(0,0)}; st = [(0,0)]
    while st:
        x,y = st.pop()
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            if L[2*y+1+dy][2*x+1+dx] == " ":
                n = (x+dx,y+dy)
                if n not in seen: seen.add(n); st.append(n)
    return len(seen) == len(cells) and all(L[2*y+1][2*x+1]==" " for x,y in cells)
w,h = int(sys.argv[1]), int(sys.argv[2])
sys.exit(0 if ok(sys.stdin.read(), w, h) else 1)
PY
run() { awk -v w=$2 -v h=$3 -v seed=$4 -f "$1"; }
n=0; bad=0
for w in 1 2 3 7 20; do for h in 1 2 5 9; do for s in 1 2 3 4 5; do
  n=$((n+1)); run "$d/maze.awk" $w $h $s | python3 "$t/v.py" $w $h || { bad=$((bad+1)); echo "bad $w $h $s"; }
done; done; done
[ $bad -eq 0 ] || { echo FAIL; exit 1; }
echo "ok $n mazes are spanning trees"
[ "$(run "$d/maze.awk" 8 5 7)" = "$(run "$d/maze.awk" 8 5 7)" ] || { echo FAIL; exit 1; }
[ "$(run "$d/maze.awk" 8 5 7)" != "$(run "$d/maze.awk" 8 5 8)" ] || { echo FAIL same; exit 1; }
echo "ok seeded and repeatable"
sed 's/^  for (i = 0; i < H; i++) { s = ""/  g[2, 2] = " "; &/' "$d/maze.awk" > "$t/sab.awk"
cmp -s "$t/sab.awk" "$d/maze.awk" && { echo FAIL sabotage not applied; exit 1; }
c=0; for s in 1 2 3 4 5 6; do run "$t/sab.awk" 6 6 $s | python3 "$t/v.py" 6 6 || c=$((c+1)); done
[ $c -ge 1 ] || { echo FAIL sabotage missed; exit 1; }
echo "ok sabotage caught $c of 6"
echo PASS
