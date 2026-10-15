#!/bin/sh
# fuzz rx.awk against grep -E; a sabotaged copy must disagree
d=$(dirname "$0"); t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
python3 - "$t" <<'PY'
import random, sys
random.seed(7); t = sys.argv[1]
with open(t + "/lines", "w") as f:
    for _ in range(200):
        f.write("".join(random.choice("abc") for _ in range(random.randint(0, 8))) + "\n")
with open(t + "/pats", "w") as f:
    for _ in range(300):
        p = "^" if random.random() < .3 else ""
        for _ in range(random.randint(1, 4)):
            p += random.choice("abc.") + ("*" if random.random() < .4 else "")
        if random.random() < .3: p += "$"
        f.write(p + "\n")
PY
run() { bad=0
  while read -r p; do
    a=$(timeout 5 awk -v re="$p" -f "$1" "$t/lines"); b=$(grep -E -e "$p" "$t/lines")
    [ "$a" = "$b" ] || bad=$((bad+1))
  done < "$t/pats"; echo $bad; }
good=$(run "$d/rx.awk")
sed 's/c == "\."/c == "Z"/' "$d/rx.awk" > "$t/bad.awk"
cmp -s "$d/rx.awk" "$t/bad.awk" && { echo "FAIL: sabotage unchanged"; exit 1; }
sab=$(run "$t/bad.awk")
echo "mismatches: real=$good sabotaged=$sab"
[ "$good" = 0 ] && [ "$sab" -gt 0 ] && { echo PASS; exit 0; }
echo FAIL; exit 1
