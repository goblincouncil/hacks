#!/bin/sh
cd "$(dirname "$0")" || exit 1
exp="1 0 0 2 10 4 40 92 352"
run(){ f=$1; i=0
 for e in $exp; do i=$((i+1))
  out=$(awk -v n=$i -f "$f"); cnt=$(echo "$out"|tail -1)
  [ "$cnt" = "$e" ] || { echo "bad count n=$i got $cnt want $e"; return 1; }
  if [ "$e" -gt 0 ]; then
   echo "$out"|head -1|python3 -c "
import sys
n=$i;c=list(map(int,sys.stdin.read().split()))
assert len(c)==n and all(1<=x<=n for x in c)
for a in range(n):
 for b in range(a+1,n):
  assert c[a]!=c[b] and abs(c[a]-c[b])!=b-a
" || { echo "invalid board n=$i"; return 1; }
  fi
 done; }
run queens.awk || { echo FAIL; exit 1; }
echo "ok counts and boards n=1..9"
awk -v n=0 -f queens.awk >/dev/null 2>&1 && { echo "bad input accepted"; exit 1; }
echo "ok bad input rejected"
sed 's/d==r-i||//;s/||d==i-r//' queens.awk > /tmp/qsab.awk
if run /tmp/qsab.awk >/dev/null 2>&1; then echo "sabotage not caught"; exit 1; fi
echo "ok sabotage caught"
echo PASS
