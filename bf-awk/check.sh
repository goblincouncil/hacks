#!/bin/sh
# Exits 0 only if bf.awk runs the example programs byte for byte
# and rejects broken programs with exit status 2.
here=$(cd "$(dirname "$0")" && pwd) || exit 1
bf="$here/bf.awk"
ex="$here/examples"
export LC_ALL=C
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
fails=0

expect() {
  name=$1; want=$2; shift 2
  if awk -f "$bf" "$@" > "$tmp/got" 2> "$tmp/err" && cmp -s "$want" "$tmp/got"; then
    echo "ok   $name"
  else
    echo "FAIL $name"; fails=$((fails + 1))
  fi
}

rejects() {
  name=$1; prog=$2
  printf '%s' "$prog" > "$tmp/bad.bf"
  awk -f "$bf" "$tmp/bad.bf" < /dev/null > /dev/null 2> "$tmp/err"
  rc=$?
  if [ "$rc" -eq 2 ] && [ -s "$tmp/err" ]; then
    echo "ok   $name"
  else
    echo "FAIL $name (exit $rc)"; fails=$((fails + 1))
  fi
}

printf 'Hello World!\n' > "$tmp/hello.want"
expect hello "$tmp/hello.want" "$ex/hello.bf" < /dev/null

printf '*' > "$tmp/times.want"
expect times-6x7 "$tmp/times.want" "$ex/times.bf" < /dev/null

printf 'abc\377\n' > "$tmp/cat.in"
cp "$tmp/cat.in" "$tmp/cat.want"
expect cat-high-byte "$tmp/cat.want" "$ex/cat.bf" < "$tmp/cat.in"

printf '\377' > "$tmp/wrap.want"
printf '%s' '-.' > "$tmp/wrap.bf"
expect wrap-minus-one "$tmp/wrap.want" "$tmp/wrap.bf" < /dev/null

printf '\000' > "$tmp/eof.want"
printf '%s' ',.' > "$tmp/eof.bf"
expect eof-reads-zero "$tmp/eof.want" "$tmp/eof.bf" < /dev/null

rejects unmatched-open '['
rejects unmatched-close ']'
rejects tape-underflow '<'

if [ "$fails" -eq 0 ]; then
  echo PASS
  exit 0
fi
echo "FAIL: $fails"
exit 1
