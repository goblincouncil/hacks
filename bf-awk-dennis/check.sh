#!/bin/sh
# exits 0 only if bf.awk runs the sample programs correctly and a sabotaged copy is caught
d=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d) || exit 1
trap 'rm -rf "$t"' EXIT
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }

[ "$(awk -f "$d/bf.awk" "$d/hello.bf" </dev/null)" = "Hello World!" ] && ok hello || bad hello

python3 -c 'print("\n".join(str(i*i) for i in range(101)))' > "$t/sq.exp"
awk -f "$d/bf.awk" "$d/squares.bf" </dev/null > "$t/sq.out"
cmp -s "$t/sq.exp" "$t/sq.out" && ok squares || bad squares

printf '+[' > "$t/open.bf"
awk -f "$d/bf.awk" "$t/open.bf" </dev/null >/dev/null 2>&1 && bad unbalanced-open || ok unbalanced-open
printf ']' > "$t/close.bf"
awk -f "$d/bf.awk" "$t/close.bf" </dev/null >/dev/null 2>&1 && bad unbalanced-close || ok unbalanced-close

# wraparound: 0 - 1 = 255 wraps; 256 pluses wrap to 0
printf -- '-.' > "$t/w.bf"
[ "$(awk -f "$d/bf.awk" "$t/w.bf" </dev/null | od -An -tu1 | tr -d ' ')" = 255 ] && ok wrap || bad wrap

# sabotage: break the + rule, must be caught
sed 's/% 256$/% 256 + 1/;s/(m\[dp\] + 1) % 256/(m[dp] + 2) % 256/' "$d/bf.awk" > "$t/bad.awk"
[ "$(timeout 5 awk -f "$t/bad.awk" "$d/hello.bf" </dev/null 2>/dev/null)" = "Hello World!" ] && bad sabotage-not-caught || ok sabotage-caught

[ $fail = 0 ] && echo PASS || echo FAILED
exit $fail
