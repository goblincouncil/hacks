#!/bin/sh
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cat > "$T/ref.py" <<'PY'
import sys,heapq,collections
d=open(sys.argv[1],'rb').read()
c=collections.Counter(d)
if len(c)<2: print(len(d) if c else 0); sys.exit()
h=list(c.values()); heapq.heapify(h); t=0
while len(h)>1:
    a=heapq.heappop(h);b=heapq.heappop(h);t+=a+b;heapq.heappush(h,a+b)
print(t)
PY
cat > "$T/val.py" <<'PY'
import sys,collections
d=open(sys.argv[1],'rb').read(); L=open(sys.argv[2]).read().split('\n')
n=int(L[0]); tab={int(l.split()[0]):l.split()[1] for l in L[1:n+1]}
bits=L[n+1] if n else ""
cs=list(tab.values())
assert set(tab)==set(d)
for i,a in enumerate(cs):
    for j,b in enumerate(cs):
        assert i==j or not b.startswith(a),"prefix"
assert len(bits)==sum(len(tab[x]) for x in d)
assert len(bits)==int(open(sys.argv[3]).read()),"not optimal"
PY
run(){ # $1 = awk script
  i=0; while [ $i -lt 25 ]; do
    n=$(python3 -c "import random;random.seed($i);print(random.choice([0,1,2,5,40,300,700]))")
    python3 -c "import random,sys;random.seed($i);k=random.choice([1,2,3,8,40,256]);sys.stdout.buffer.write(bytes(random.randrange(k)*random.choice([1,3]) %256 for _ in range($n)))" > "$T/in"
    od -An -v -tu1 -w16 "$T/in" | gawk -f "$1" > "$T/enc" || return 1
    python3 "$T/ref.py" "$T/in" > "$T/opt"
    [ "$n" -gt 0 ] && { python3 "$T/val.py" "$T/in" "$T/enc" "$T/opt" 2>/dev/null || return 1; }
    gawk -v d=1 -f "$1" < "$T/enc" > "$T/out" || return 1
    cmp -s "$T/in" "$T/out" || return 1
    i=$((i+1))
  done
}
run huff.awk || { echo FAIL real; exit 1; }
echo "ok 25 random inputs: optimal, prefix-free, round-trip"
printf 'x' | od -An -tu1 | gawk -f huff.awk | gawk -v d=1 -f huff.awk | grep -qx x || { echo FAIL single; exit 1; }
echo "ok single symbol"
printf '3\n65 0\n66 1\n67 00\n' | gawk -v d=1 -f huff.awk >/dev/null 2>&1 && true
# sabotage: pick heaviest instead of lightest -> not optimal
sed 's/w\[k\]<w\[a\]/w[k]>w[a]/; s/w\[k\]<w\[b\]/w[k]>w[b]/' huff.awk > "$T/bad.awk"
if run "$T/bad.awk"; then echo FAIL sabotage-not-caught; exit 1; fi
echo "ok sabotage caught"
echo PASS
