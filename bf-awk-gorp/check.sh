#!/bin/sh
cd "$(dirname "$0")" || exit 1
f=0
t=$(mktemp -d)
H='++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.'
printf '%s' "$H" > $t/h.bf
[ "$(awk -f bf.awk $t/h.bf)" = "Hello World!" ] && echo "ok hello" || { echo FAIL hello; f=1; }
printf ',[.,]' > $t/c.bf
[ "$(awk -v inp=gorp42 -f bf.awk $t/c.bf)" = "gorp42" ] && echo "ok cat" || { echo FAIL cat; f=1; }
printf '%s' '-.' > $t/w.bf
[ "$(awk -f bf.awk $t/w.bf | od -An -tu1 | tr -d ' ')" = "255" ] && echo "ok wrap" || { echo FAIL wrap; f=1; }
printf '[[]' > $t/b.bf
[ "$(awk -f bf.awk $t/b.bf)" = "?" ] && echo "ok badbracket" || { echo FAIL bad; f=1; }
sed 's/% 256/% 255/' bf.awk > $t/s.awk
[ "$(awk -f $t/s.awk $t/w.bf | od -An -tu1 | tr -d ' ')" = "255" ] && { echo FAIL sabotage-not-caught; f=1; } || echo "ok sabotage caught"
rm -rf $t
[ $f = 0 ] && echo PASS
exit $f
