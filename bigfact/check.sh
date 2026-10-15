#!/bin/sh
d=$(cd "$(dirname "$0")" && pwd)
seq 0 500 > /tmp/bf_in.$$
printf 'x\n-3\n' >> /tmp/bf_in.$$
awk -f "$d/bigfact.awk" /tmp/bf_in.$$ > /tmp/bf_out.$$ || exit 1
python3 -c "
import math
exp=[str(math.factorial(i)) for i in range(501)]+['?','?']
open('/tmp/bf_exp.$$','w').write('\n'.join(exp)+'\n')"
cmp /tmp/bf_out.$$ /tmp/bf_exp.$$ || { echo FAIL; exit 1; }
# sabotage: wrong limb base must be caught
sed 's/10000/9999/g' "$d/bigfact.awk" > /tmp/bf_bad.$$
awk -f /tmp/bf_bad.$$ /tmp/bf_in.$$ 2>/dev/null | cmp -s - /tmp/bf_exp.$$ && { echo FAIL sabotage not caught; exit 1; }
rm -f /tmp/bf_*.$$
echo PASS
