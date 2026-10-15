#!/bin/sh
# exits 0 only if bf.awk agrees with the independent Python interpreter
cd "$(dirname "$0")" || exit 1
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
[ "$(awk -f bf.awk hello.bf)" = "Hello World!" ] && ok hello || bad hello
awk -f bf.awk squares.bf > "$t/a"; python3 -I ref.py squares.bf > "$t/b"
cmp -s "$t/a" "$t/b" && [ "$(wc -l < "$t/a")" -eq 101 ] && ok squares || bad squares
printf 'ab\ncd\n' | awk -f bf.awk cat.bf > "$t/a"; printf 'ab\ncd\n' | python3 -I ref.py cat.bf > "$t/b"
cmp -s "$t/a" "$t/b" && [ "$(cat "$t/a")" = "ab
cd" ] && ok cat || bad cat
[ "$(printf '\005\003' | awk -f bf.awk add.bf | od -An -tu1 | tr -d ' ')" = 8 ] && ok add || bad add
# wraparound: 255 + 1 -> 0, 0 - 1 -> 255
echo '-.+.' > "$t/w.bf"
[ "$(awk -f bf.awk "$t/w.bf" | od -An -tu1 | tr -s ' ')" = " 255 0" ] && ok wrap || bad wrap
for p in '[' ']' '+]' '[[]' '<'; do
  echo "$p" > "$t/e.bf"
  awk -f bf.awk "$t/e.bf" >/dev/null 2>&1; r=$?
  [ $r -ne 0 ] && ok "reject $p" || bad "reject $p"
done
awk -f bf.awk "$t/none.bf" >/dev/null 2>&1; [ $? -eq 2 ] && ok missing || bad missing
# sabotage: wrong wrap must be caught
sed 's/+ 255/+ 254/' bf.awk > "$t/s.awk"
[ "$(awk -f "$t/s.awk" "$t/w.bf" | od -An -tu1 | tr -s ' ')" = " 255 0" ] && bad sabotage || ok sabotage
[ $fail -eq 0 ] && echo PASS
exit $fail
