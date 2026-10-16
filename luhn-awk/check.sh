#!/bin/sh
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
python3 - > "$T/in" <<'PY'
import random
random.seed(7)
print("79927398713"); print("79927398710"); print("0"); print("abc")
for _ in range(300):
    n="".join(random.choice("0123456789") for _ in range(random.randint(1,19)))
    print(n); print("gen "+n)
PY
python3 ref.py < "$T/in" > "$T/exp"
awk -f luhn.awk < "$T/in" > "$T/got"
cmp -s "$T/exp" "$T/got" || { echo FAIL real; exit 1; }
grep -qx '79927398713 ok' "$T/got" || { echo FAIL known; exit 1; }
sed 's/d -= 9/d -= 8/' luhn.awk > "$T/bad.awk"
awk -f "$T/bad.awk" < "$T/in" > "$T/bgot"
cmp -s "$T/exp" "$T/bgot" && { echo FAIL sabotage not caught; exit 1; }
echo "ok: $(wc -l < "$T/in") lines match reference, sabotage caught"
echo PASS
