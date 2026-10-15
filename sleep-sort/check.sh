#!/bin/sh
# check.sh - exits 0 only if sleepsort.sh really sorts.
here=$(cd "$(dirname "$0")" && pwd) || exit 1
ss="$here/sleepsort.sh"
fail() { echo "FAIL: $1" >&2; exit 1; }
want=$(printf '%s\n' 5 3 9 1 0 12 7 3 | sort -n)
got=$(sh "$ss" 5 3 9 1 0 12 7 3)
[ "$got" = "$want" ] || fail "arguments: output not sorted"
want=$(printf '%s\n' 0 1 2 3 4 5 6 7 8 9 10)
got=$(printf '10\n9\n8\n7\n6\n5\n4\n3\n2\n1\n0\n' | sh "$ss")
[ "$got" = "$want" ] || fail "stdin reversed: output not sorted"
want=$(printf '%s\n' 0 0 2 2 2 | sort -n)
got=$(sh "$ss" 2 0 2 0 2)
[ "$got" = "$want" ] || fail "duplicates: output not sorted"
if sh "$ss" 3 x 2 >/dev/null 2>&1; then fail "accepted a non-integer"; fi
if sh "$ss" -4 >/dev/null 2>&1; then fail "accepted a negative"; fi
tmp=$(mktemp -d) || fail "mktemp"
trap 'rm -rf "$tmp"' EXIT
printf '%s\n' 'for n in "$@"; do echo "$n"; done' > "$tmp/naive.sh"
want=$(printf '%s\n' 5 3 9 1 | sort -n)
got=$(sh "$tmp/naive.sh" 5 3 9 1)
[ "$got" != "$want" ] || fail "sabotaged copy passed"
echo PASS
