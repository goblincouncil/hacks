#!/bin/sh
# run from anywhere; needs gawk, python3
cd "$(dirname "$0")" || exit 1
export LC_ALL=C
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL $1"; exit 1; }
[ "$(echo banana | gawk -v mode=enc -f bwt.awk)" = 'annb$aa' ] || fail banana
echo ok banana
python3 -I - "$T" <<'PY'
import random,sys
random.seed(7); a="abcab XYZ.,~!01"
open(sys.argv[1]+"/in","w").write("".join("".join(random.choice(a) for _ in range(random.randint(0,60)))+"\n" for _ in range(80)))
PY
gawk -v mode=enc -f bwt.awk "$T/in" > "$T/enc" || fail enc
python3 -I ref.py < "$T/in" > "$T/ref" || fail ref
cmp -s "$T/enc" "$T/ref" || fail "match reference"
echo ok reference
grep -v '^\$$' "$T/enc" > /dev/null
gawk -v mode=dec -f bwt.awk "$T/enc" > "$T/dec" || fail dec
cmp -s "$T/in" "$T/dec" || fail roundtrip
echo ok roundtrip
echo 'a$b' | gawk -v mode=enc -f bwt.awk >/dev/null && fail baddollar
echo 'abc' | gawk -v mode=dec -f bwt.awk >/dev/null && fail baddec
echo ok badinput
sed 's/ + 1\] = substr(t, i + 2) substr(t, 1, i + 1)/ + 1] = substr(t, i + 2) substr(t, 1, i)/' bwt.awk > "$T/bad.awk"
cmp -s bwt.awk "$T/bad.awk" && fail sabotage-noop
gawk -v mode=enc -f "$T/bad.awk" "$T/in" 2>/dev/null | cmp -s - "$T/ref" && fail sabotage-missed
echo ok sabotage-caught
echo PASS
