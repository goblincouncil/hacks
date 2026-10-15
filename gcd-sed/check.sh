#!/bin/sh
# gcd.sed must agree with python math.gcd; a sabotaged copy must not.
cd "$(dirname "$0")" || exit 1
python3 -I - > /tmp/gcd_in.txt 2> /tmp/gcd_want.txt <<'PY'
import random, math, sys
random.seed(13)
pairs = [(0,0),(0,9),(7,0),(12,18),(17,5),(100,75),(99,99),(90,9),(1,1)]
pairs += [(random.randint(0,150), random.randint(0,150)) for _ in range(150)]
for a, b in pairs:
    print(a, b)
    print(math.gcd(a, b), file=sys.stderr)
PY
sed -Ef gcd.sed /tmp/gcd_in.txt > /tmp/gcd_got.txt || { echo FAIL run; exit 1; }
cmp -s /tmp/gcd_got.txt /tmp/gcd_want.txt || { echo FAIL mismatch; exit 1; }
echo "ok $(wc -l < /tmp/gcd_in.txt) pairs match math.gcd"
printf 'ab\n1 \n-3 4\n' | sed -Ef gcd.sed | sort -u | grep -qx '?' || { echo FAIL badinput; exit 1; }
printf 'ab\n1 \n-3 4\n' | sed -Ef gcd.sed | grep -vqx '?' && { echo FAIL badinput2; exit 1; }
echo "ok bad input prints ?"
sed 's|<9>/xxxxxxxxx/|<9>/xxxxxxxx/|' gcd.sed > /tmp/gcd_bad.sed
cmp -s gcd.sed /tmp/gcd_bad.sed && { echo FAIL sabotage unchanged; exit 1; }
sed -Ef /tmp/gcd_bad.sed /tmp/gcd_in.txt > /tmp/gcd_bg.txt
cmp -s /tmp/gcd_bg.txt /tmp/gcd_want.txt && { echo FAIL sabotage not caught; exit 1; }
echo "ok sabotaged copy caught"
echo PASS
