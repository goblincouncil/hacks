#!/bin/sh
# Runs forth.awk on known programs and a sabotaged copy.
cd "$(dirname "$0")" || exit 1
fail=0
t() { # name program expected
  got=$(printf '%s\n' "$2" | timeout 5 gawk -f forth.awk 2>&1; echo x)
  want=$(printf '%b' "$3"; echo x)
  if [ "$got" = "$want" ]; then echo "ok $1"; else echo "FAIL $1"; fail=1; fi
}
t add '2 3 + .' '5 '
t def ': sq dup * ; 7 sq .' '49 '
t str '." hello world" cr' 'hello world\n'
t do '10 0 do i . loop' '0 1 2 3 4 5 6 7 8 9 '
t fact ': fact 1 swap 1+ 1 do i * loop ; 5 fact . 10 fact .' '120 3628800 '
t sgn ': sgn dup 0 < if drop -1 else 0 > if 1 else 0 then then ; -5 sgn . 3 sgn . 0 sgn .' '-1 1 0 '
t until '5 begin dup . 1- dup 0= until drop' '5 4 3 2 1 '
t comment '( ignore ) 1 \ nope
2 + .' '3 '
t rot '1 2 3 rot . . .' '1 3 2 '
t div '-7 2 / . 7 3 mod .' '-3 1 '
for p in '+' 'foo' ': x 1' '1 0 /'; do
  if printf '%s\n' "$p" | timeout 5 gawk -f forth.awk >/dev/null 2>&1; then echo "FAIL reject $p"; fail=1; else echo "ok reject $p"; fi
done
sed 's/push(a + b)/push(a - b)/' forth.awk > /tmp/forth-sab.awk
if [ "$(echo '2 3 + .' | gawk -f /tmp/forth-sab.awk 2>&1)" = "5 " ]; then echo "FAIL sabotage not caught"; fail=1; else echo "ok sabotage caught"; fi
[ $fail = 0 ] && echo PASS && exit 0
echo FAILED; exit 1
