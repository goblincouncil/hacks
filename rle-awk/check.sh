#!/bin/sh
d=$(dirname "$0"); t=$(mktemp -d)
python3 - "$t" <<'P'
import random,sys
random.seed(3)
with open(sys.argv[1]+"/in","w") as f:
    for _ in range(200):
        f.write("".join(random.choice("abcxyz ") * random.randint(1,12) for _ in range(random.randint(0,8)))+"\n")
P
python3 - "$t" <<'P'
import itertools,sys
t=sys.argv[1]
with open(t+"/exp","w") as o:
    for l in open(t+"/in").read().split("\n")[:-1]:
        o.write("".join(str(len(list(g)))+k for k,g in itertools.groupby(l))+"\n")
P
awk -v mode=enc -f "$d/rle.awk" "$t/in" > "$t/enc" && cmp "$t/enc" "$t/exp" || { echo FAIL enc; exit 1; }
awk -v mode=dec -f "$d/rle.awk" "$t/enc" | cmp - "$t/in" || { echo FAIL roundtrip; exit 1; }
sed 's/j-i/j-i+1/' "$d/rle.awk" > "$t/bad.awk"
awk -v mode=enc -f "$t/bad.awk" "$t/in" | cmp -s - "$t/exp" && { echo FAIL sabotage; exit 1; }
rm -rf "$t"; echo PASS
