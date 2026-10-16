#!/bin/sh
# exits 0 only if b64.awk matches python base64 and a sabotaged copy fails
cd "$(dirname "$0")" || exit 1
export LC_ALL=C
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
enc() { od -An -v -tu1 "$2" | gawk -f "$1"; }
fail() { echo "FAIL $*"; exit 1; }
run() { # script
  s=$1; n=0
  for len in 0 1 2 3 4 5 6 7 8 9 10 55 56 57 100 255 256 700; do
    python3 -I -c "import os,sys;sys.stdout.buffer.write(os.urandom($len))" > "$T/in"
    python3 -I -c "import base64,sys;print(base64.b64encode(open(sys.argv[1],'rb').read()).decode())" "$T/in" > "$T/want"
    enc "$s" "$T/in" > "$T/got" 2>/dev/null
    cmp -s "$T/want" "$T/got" || return 1
    gawk -v d=1 -f "$s" "$T/want" > "$T/back" 2>/dev/null
    cmp -s "$T/in" "$T/back" || return 1
  done
  printf '\000\000\000\377\377' > "$T/in"
  enc "$s" "$T/in" | grep -qx 'AAAA//8=' || return 1
  return 0
}
run b64.awk || fail "real script"
echo "ok random and padding lengths 0..700 match python, round trip with NULs"
printf 'TWFu' | gawk -v d=1 -f b64.awk | grep -qx Man || fail decode
echo ok decode Man
for bad in 'TWF' 'TW=u' 'T!Fu' '===='; do
  echo "$bad" | gawk -v d=1 -f b64.awk >/dev/null 2>&1 && fail "accepted $bad"
done
echo ok bad input refused
echo 12 999 | gawk -f b64.awk >/dev/null 2>&1 && fail "accepted byte 999"
echo ok bad byte refused
sed 's/ABCDEFGHIJKLMNOPQRSTUVWXYZabc/ABCDEFGHIJKLMNOPQRSTUVWXYZacb/' b64.awk > "$T/s1.awk"
sed 's/"="))/"A"))/;s/(r > 2 ? substr(A, x % 64 + 1, 1) : "=")/(r > 2 ? substr(A, x % 64 + 1, 1) : "")/' b64.awk > "$T/s2.awk"
for k in s1 s2; do
  cmp -s b64.awk "$T/$k.awk" && fail "$k sabotage did not change file"
  run "$T/$k.awk" && fail "sabotage $k not caught"
done
echo ok sabotaged copies caught
echo PASS
