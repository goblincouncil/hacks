#!/bin/sh
# add-sed check: random sums vs python, edge cases, bad input, sabotage
cd "$(dirname "$0")" || exit 1
fail=0
python3 - > /tmp/addcases.txt <<'P'
import random
random.seed(7)
c=[(0,0),(1,0),(0,1),(999,1),(9999999999,1),(5,5),(10**60-1,1),(123,98765)]
for _ in range(300):
    c.append((random.randrange(10**random.randint(1,40)),random.randrange(10**random.randint(1,40))))
for a,b in c: print(a,b,a+b)
P
bad=0
while read a b s; do
  got=$(echo "$a $b" | sed -Ef add.sed)
  [ "$got" = "$s" ] || { bad=$((bad+1)); echo "mismatch $a $b: $got != $s"; }
done < /tmp/addcases.txt
[ $bad -eq 0 ] && echo "ok sums ($(wc -l < /tmp/addcases.txt))" || fail=1
for x in "abc" "1 2 3" "" "12"; do
  got=$(echo "$x" | sed -Ef add.sed)
  [ "$got" = "?" ] || { echo "bad input '$x' gave '$got'"; fail=1; }
done
echo "ok bad input"
sed 's/xxxxxxxxx,/xxxxxxxx,/' add.sed > /tmp/add-bad.sed
cmp -s add.sed /tmp/add-bad.sed && { echo "sabotage did not change script"; fail=1; }
got=$(echo "9 9" | sed -Ef /tmp/add-bad.sed)
[ "$got" != "18" ] && echo "ok sabotage caught" || { echo "sabotage survived"; fail=1; }
[ $fail -eq 0 ] && { echo PASS; exit 0; }
echo FAIL; exit 1
