#!/bin/sh
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL: $1"; exit 1; }
[ "$(echo 'sos' | awk -v mode=enc -f morse.awk)" = "... --- ..." ] || fail sos
[ "$(echo 'hello world 42' | awk -v mode=enc -f morse.awk)" = ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / ....- ..---" ] || fail hello
cat > "$T/ref.py" <<'PY'
import sys,random
t="A .-,B -...,C -.-.,D -..,E .,F ..-.,G --.,H ....,I ..,J .---,K -.-,L .-..,M --,N -.,O ---,P .--.,Q --.-,R .-.,S ...,T -,U ..-,V ...-,W .--,X -..-,Y -.--,Z --..,0 -----,1 .----,2 ..---,3 ...--,4 ....-,5 .....,6 -....,7 --...,8 ---..,9 ----."
M=dict(x.split() for x in t.split(","))
random.seed(7)
al="abcdefghijklmnopqrstuvwxyz0123456789"
with open(sys.argv[1],"w") as a, open(sys.argv[2],"w") as b, open(sys.argv[3],"w") as c:
    for _ in range(300):
        ws=["".join(random.choice(al) for _ in range(random.randint(1,8))) for _ in range(random.randint(1,6))]
        a.write(" ".join(ws)+"\n")
        b.write(" / ".join(" ".join(M[ch.upper()] for ch in w) for w in ws)+"\n")
        c.write(" ".join(ws).upper()+"\n")
PY
python3 -I "$T/ref.py" "$T/in" "$T/morse" "$T/up"
awk -v mode=enc -f morse.awk "$T/in" | cmp -s - "$T/morse" || fail "encode differs from python"
echo "ok encode matches python on 300 lines"
awk -v mode=dec -f morse.awk "$T/morse" | cmp -s - "$T/up" || fail "decode differs"
echo "ok decode matches"
awk -v mode=enc -f morse.awk "$T/in" | awk -v mode=dec -f morse.awk | cmp -s - "$T/up" || fail roundtrip
echo "ok round trip"
[ "$(echo '.-.-.-' | awk -v mode=dec -f morse.awk)" = "?" ] || fail unknown
echo "ok unknown code prints ?"
sed 's/B -\.\.\./B -..-/' morse.awk > "$T/bad.awk"
if awk -v mode=enc -f "$T/bad.awk" "$T/in" | cmp -s - "$T/morse"; then fail "sabotage not caught"; fi
echo "ok sabotaged copy caught"
echo PASS
