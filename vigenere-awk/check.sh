#!/bin/sh
cd "$(dirname "$0")" || exit 1
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
fail() { echo "FAIL: $1"; exit 1; }
[ "$(echo ATTACKATDAWN | awk -v key=LEMON -f vigenere.awk)" = LXFOPVEFRNHR ] || fail classic
echo ok classic
python3 - "$t" <<'PY'
import random, sys
random.seed(7); a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ  .,!0123"
open(sys.argv[1] + "/in", "w").write("".join("".join(random.choice(a) for _ in range(random.randint(0, 40))) + "\n" for _ in range(200)))
PY
for key in a Lemon zzy secretkey; do
  for m in enc dec; do
    awk -v key=$key -v mode=$m -f vigenere.awk "$t/in" > "$t/o1"
    python3 ref.py $key $m < "$t/in" > "$t/o2"
    cmp -s "$t/o1" "$t/o2" || fail "$key $m"
  done
  awk -v key=$key -f vigenere.awk "$t/in" | awk -v key=$key -v mode=dec -f vigenere.awk | cmp -s - "$t/in" || fail "roundtrip $key"
done
echo ok "200 lines x 4 keys x 2 modes match python, round-trip"
echo x | awk -v key=a1 -f vigenere.awk >/dev/null 2>&1 && fail "bad key accepted"
echo x | awk -f vigenere.awk >/dev/null 2>&1 && fail "empty key accepted"
echo ok bad-key
sed 's/% 26 + 26) % 26/% 25 + 25) % 25/' vigenere.awk > "$t/bad.awk"
awk -v key=Lemon -f "$t/bad.awk" "$t/in" | cmp -s - "$t/o1" && fail "sabotage not caught"
awk -v key=Lemon -f "$t/bad.awk" "$t/in" | cmp -s - "$t/in" && fail "sabotage noop"
echo ok sabotage-caught
echo PASS
