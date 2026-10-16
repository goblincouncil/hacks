#!/bin/sh
d=$(dirname "$0"); A="$d/sudoku.awk"
cat > /tmp/sk_in.$$ <<'EOT'
530070000600195000098000060800060003400803001700020006060000280000419005000080079
003020600900305001001806400008102900700000008006708200002609500800203009005010300
000000907000420180000705026100904000050000040000507009920108000034059000507000000
EOT
cat > /tmp/chk.py <<'EOT'
import sys
inp=[l.strip() for l in open(sys.argv[1])]
out=[l.strip() for l in open(sys.argv[2])]
assert len(inp)==len(out), "line count"
for a,b in zip(inp,out):
    assert len(b)==81 and b.isdigit(), "bad output "+b
    for i in range(81):
        assert a[i] in ".0" or a[i]==b[i], "clue changed"
    for k in range(9):
        assert set(b[k*9:k*9+9])==set("123456789"), "row"
        assert set(b[k::9])==set("123456789"), "col"
        r,c=k//3*3,k%3*3
        assert set(b[(r+i)*9+c+j] for i in range(3) for j in range(3))==set("123456789"), "box"
EOT
awk -f "$A" /tmp/sk_in.$$ > /tmp/sk_out.$$ && python3 -I /tmp/chk.py /tmp/sk_in.$$ /tmp/sk_out.$$ || { echo FAIL real; exit 1; }
echo "ok: 3 puzzles solved and valid"
# known answer for the classic puzzle
[ "$(head -1 /tmp/sk_out.$$)" = 534678912672195348198342567859761423426853791713924856961537284287419635345286179 ] || { echo FAIL known; exit 1; }
echo "ok: known solution"
# dot form
tr 0 . < /tmp/sk_in.$$ | awk -f "$A" | cmp -s - /tmp/sk_out.$$ || { echo FAIL dots; exit 1; }
echo "ok: dot blanks"
# bad input
r=$(printf '%s\n' 55 11"$(printf '0%.0s' $(seq 79))" abc | awk -f "$A" | tr -d '\n')
[ "$r" = "???" ] || { echo FAIL bad "$r"; exit 1; }
echo "ok: bad input and conflicting clues give ?"
# sabotage: box check removed must be caught
sed 's/g\[(br + int(i \/ 3)) \* 9 + bc + i % 3\] == v/0/' "$A" > /tmp/sk_bad.awk
awk -f /tmp/sk_bad.awk /tmp/sk_in.$$ > /tmp/sk_bad_out.$$
if python3 -I /tmp/chk.py /tmp/sk_in.$$ /tmp/sk_bad_out.$$ 2>/dev/null; then echo FAIL sabotage not caught; exit 1; fi
echo "ok: sabotaged copy caught"
rm -f /tmp/sk_*.$$ /tmp/sk_bad.awk /tmp/chk.py
echo PASS
