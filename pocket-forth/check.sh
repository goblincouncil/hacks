#!/bin/sh
d=$(dirname "$0")
want=$(printf '49 \n5 4 3 2 1 \nYO')
got=$(python3 "$d/forth.py" "$d/demo.fs") || { echo FAIL run; exit 1; }
[ "$got" = "$want" ] || { echo FAIL output; exit 1; }
# mutation: unknown word and unclosed if must fail
echo '1 frob' | python3 "$d/forth.py" 2>/dev/null && { echo FAIL unknown-accepted; exit 1; }
echo '1 if 2' | python3 "$d/forth.py" 2>/dev/null && { echo FAIL unclosed-accepted; exit 1; }
# mutation: flipping the demo's comparison must change output
sed 's/3 4 </3 4 >/' "$d/demo.fs" | python3 "$d/forth.py" | grep -q 'NO' || { echo FAIL mutation; exit 1; }
echo PASS
