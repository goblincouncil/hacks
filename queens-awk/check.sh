#!/bin/sh
d=$(dirname "$0"); f=0
py='
import sys
n=int(sys.argv[1])
def go(r,c,a,b):
    if r==n: return 1
    return sum(go(r+1,c|1<<x,a|1<<(r+x),b|1<<(r-x+n)) for x in range(n) if not(c>>x&1 or a>>(r+x)&1 or b>>(r-x+n)&1))
print(go(0,0,0,0))'
for n in 1 2 3 4 5 6 7 8; do
  a=$(awk -v n=$n -f $d/queens.awk | tail -1 | sed 's/.*=//')
  p=$(python3 -c "$py" $n)
  [ "$a" = "$p" ] && echo "ok n=$n $a" || { echo "FAIL n=$n awk=$a py=$p"; f=1; }
done
[ "$(awk -v n=8 -f $d/queens.awk | tail -1)" = "n=8 solutions=92" ] || { echo FAIL 92; f=1; }
awk -v n=0 -f $d/queens.awk >/dev/null 2>&1 && { echo FAIL bad-input; f=1; } || echo ok bad-input
# board validity: 6 queens rows, one per row/col
awk -v n=6 -f $d/queens.awk | head -6 | awk '{for(i=1;i<=NF;i++)if($i=="Q"){q++;c[i]++}} END{for(i in c)if(c[i]!=1)bad=1; exit (q!=6||bad)}' && echo ok board || { echo FAIL board; f=1; }
# sabotage: drop diagonal check, must be caught
sed 's/ \&\& !((r-c) in E)//' $d/queens.awk > /tmp/q_bad.awk
b=$(awk -v n=6 -f /tmp/q_bad.awk | tail -1)
[ "$b" != "n=6 solutions=4" ] && echo ok sabotage-caught || { echo FAIL sabotage; f=1; }
[ $f = 0 ] && echo PASS; exit $f
