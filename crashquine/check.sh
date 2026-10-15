#!/bin/sh
# crashquine check: exits 0 only if crashquine.py is a real crash-report quine
# and five sabotaged copies are all caught.
set -u
cd "$(dirname "$0")" || exit 1
HERE=$(pwd)
Q="$HERE/crashquine.py"
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
pass=0
fail=0
ok()  { echo "ok   $1"; pass=$((pass+1)); }
bad() { echo "FAIL $1"; fail=$((fail+1)); }

# is_cq FILE: returns 0 only if FILE crashes into a traceback that is its own source
is_cq() {
  f=$1
  python3 "$f" >"$T/out" 2>"$T/err"
  [ $? -eq 1 ] || return 1
  [ ! -s "$T/out" ] || return 1
  [ "$(head -n1 "$T/err")" = "Traceback (most recent call last):" ] || return 1
  tail -n1 "$T/err" | grep -q '^QuineError: ' || return 1
  n=$(grep -c '^  File "crashquine.py", line [0-9]*, in <module>$' "$T/err")
  [ "$n" -eq "$(wc -l <"$f")" ] || return 1
  sed -n 's/^    //p' "$T/err" >"$T/rebuilt.py"
  cmp -s "$T/rebuilt.py" "$f" || return 1
  python3 "$T/rebuilt.py" >/dev/null 2>"$T/err2"
  [ $? -eq 1 ] || return 1
  cmp -s "$T/err" "$T/err2" || return 1
  mkdir -p "$T/empty"
  (cd "$T/empty" && python3 - <"$f" >/dev/null 2>"$T/err3")
  cmp -s "$T/err" "$T/err3" || return 1
  return 0
}

[ -s "$Q" ] && ok "crashquine.py exists" || bad "crashquine.py missing"

python3 "$Q" >"$T/o" 2>"$T/e"; rc=$?
[ "$rc" -eq 1 ] && ok "exits 1" || bad "exit code was $rc"
[ ! -s "$T/o" ] && ok "stdout is empty" || bad "wrote to stdout"
sed -n 's/^    //p' "$T/e" >"$T/r.py"
cmp -s "$T/r.py" "$Q" && ok "quoted code lines rebuild the file byte for byte" || bad "rebuild differs"
n=$(grep -c '^  File "crashquine.py"' "$T/e")
[ "$n" -eq "$(wc -l <"$Q")" ] && ok "one frame per line ($n)" || bad "frames $n"
is_cq "$Q" && ok "full quine check (rebuild crashes the same, stdin from empty dir the same)" || bad "full quine check"
grep -q 'open\|__file__\|argv\|inspect' "$Q" && bad "reads itself" || ok "never reads its own file"
(cd "$T" && python3 "$HERE/gen.py") && cmp -s "$T/crashquine.py" "$Q" && ok "gen.py reproduces crashquine.py" || bad "gen.py output differs"

# sabotage: every one of these must be rejected
sed '/^sys.exit(1)$/d' "$Q" >"$T/s1.py"
sed '2s/^import sys$/import sys,os/' "$Q" >"$T/s2.py"
{ cat "$Q"; echo '# one more line'; } >"$T/s3.py"
sed 's/stderr/stdout/g' "$Q" >"$T/s4.py"
cat >"$T/s5.py" <<'EOF'
import sys
L=open(sys.argv[0]).read().split("\n")[:-1]
w=sys.stderr.write
w("Traceback (most recent call last):\n")
for i,l in enumerate(L):w('  File "crashquine.py", line %d, in <module>\n    %s\n'%(i+1,l))
w("QuineError: the bug is the program\n")
sys.exit(1)
EOF
for s in "s1:no exit line" "s2:body edited, s not" "s3:extra line" "s4:crash on stdout" "s5:cheat that reads its own file"; do
  k=${s%%:*}; why=${s#*:}
  is_cq "$T/$k.py" && bad "sabotage $k ($why) was accepted" || ok "sabotage $k ($why) caught"
done

echo "$pass ok, $fail failed"
if [ "$fail" -eq 0 ] && [ "$pass" -gt 0 ]; then echo PASS; exit 0; fi
echo FAIL
exit 1
