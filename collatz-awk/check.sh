#!/bin/sh
# exits 0 only if collatz.awk matches an independent python version
d=$(cd "$(dirname "$0")" && pwd)
seq 1 2000 | awk -f "$d/collatz.awk" > /tmp/c_awk.$$ || { echo FAIL awk; exit 1; }
python3 - > /tmp/c_py.$$ <<'PY'
for i in range(1,2001):
    n=i;s=0;p=n
    while n!=1:
        n = 3*n+1 if n&1 else n>>1
        s+=1; p=max(p,n)
    print(i,s,p)
PY
cmp -s /tmp/c_awk.$$ /tmp/c_py.$$ || { echo FAIL mismatch; exit 1; }
echo ok 2000 match
[ "$(echo 27 | awk -f "$d/collatz.awk")" = "27 111 9232" ] || { echo FAIL 27; exit 1; }
echo ok 27
echo abc | awk -f "$d/collatz.awk" >/dev/null && { echo FAIL badinput; exit 1; }
echo ok bad input
sed 's/s++/s+=2/' "$d/collatz.awk" > /tmp/c_bad.$$
seq 1 50 | awk -f /tmp/c_bad.$$ 2>/dev/null | head -50 > /tmp/c_b.$$
seq 1 50 | awk -f "$d/collatz.awk" > /tmp/c_g.$$
cmp -s /tmp/c_b.$$ /tmp/c_g.$$ && { echo FAIL sabotage not caught; exit 1; }
echo ok sabotage caught
rm -f /tmp/c_*.$$
echo PASS
