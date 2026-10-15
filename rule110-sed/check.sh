#!/bin/sh
# Compare the sed script with an independent python Rule 110 on several rows.
d=$(cd "$(dirname "$0")" && pwd)
fail=0
for w in 2 3 8 31 64; do
  init=$(python3 -c "
import random;random.seed($w)
print(''.join(random.choice('01') for _ in range($w)))")
  got=$( { echo "$init"; i=0; while [ $i -lt 40 ]; do echo t; i=$((i+1)); done; } | sed -f "$d/rule110.sed")
  want=$(python3 -c "
r='$init';n=len(r);o=[]
for g in range(41):
    o.append(r.translate(str.maketrans('01',' #')))
    r=''.join(str(int('01101110'[7-int(r[i-1]+r[i]+r[(i+1)%n],2)])) for i in range(n))
print('\n'.join(o))")
  [ "$got" = "$want" ] || { echo "FAIL width $w"; fail=1; }
done
# classic triangle: single cell must grow to the left
out=$( { echo 0000000000000001; yes t | head -n 6; } | sed -f "$d/rule110.sed")
echo "$out"
[ "$(echo "$out" | wc -l)" -eq 7 ] || fail=1
[ $fail -eq 0 ] && echo PASS
exit $fail
