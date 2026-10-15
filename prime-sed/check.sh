#!/bin/sh
d=$(dirname "$0")
seq 0 2000 > /tmp/ps_in.$$
sed -E -f "$d/prime.sed" /tmp/ps_in.$$ > /tmp/ps_out.$$ || exit 1
python3 -c '
for n in range(2001):
    p=n>1 and all(n%i for i in range(2,int(n**.5)+1))
    print(n,"prime" if p else "composite")' > /tmp/ps_exp.$$
cmp /tmp/ps_out.$$ /tmp/ps_exp.$$ || { echo FAIL; exit 1; }
printf 'abc\n\n' | sed -E -f "$d/prime.sed" | grep -c '^?' | grep -qx 2 || { echo FAIL bad input; exit 1; }
# sabotage: a broken copy must be caught (small range, it is slow)
sed 's|xx\$/b yes|xxx$/b yes|' "$d/prime.sed" > /tmp/ps_bad.$$
cmp -s "$d/prime.sed" /tmp/ps_bad.$$ && { echo FAIL sabotage not applied; exit 1; }
seq 0 30 | sed -E -f /tmp/ps_bad.$$ > /tmp/ps_badout.$$
head -31 /tmp/ps_exp.$$ | cmp -s - /tmp/ps_badout.$$ && { echo FAIL sabotage not caught; exit 1; }
rm -f /tmp/ps_*.$$
echo PASS
