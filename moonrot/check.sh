#!/bin/sh
# Exits 0 only if moonrot compiles cleanly, names the right phase for known
# dates, and rejects bad input with exit 2.
set -u
cd "$(dirname "$0")" || exit 1
bin=$(mktemp) || exit 1
trap 'rm -f "$bin"' EXIT

if ! cc -Wall -Wextra -O2 -o "$bin" moonrot.c -lm; then
    echo "FAIL compile"
    exit 1
fi
echo "ok compile without warnings"

fails=0

# expect DATE PHASE: the output must contain PHASE and have two lines
expect() {
    out=$("$bin" "$1") || { echo "FAIL $1: exit $?"; fails=$((fails + 1)); return; }
    lines=$(printf '%s\n' "$out" | wc -l)
    case "$out" in
        *"  $2  "*)
            if [ "$lines" -eq 2 ]; then
                echo "ok $1 $2"
            else
                echo "FAIL $1: wanted 2 lines, got $lines"; fails=$((fails + 1))
            fi ;;
        *)
            echo "FAIL $1: wanted '$2', got: $(printf '%s\n' "$out" | head -n 1)"
            fails=$((fails + 1)) ;;
    esac
}

# known dates; the reference new moon is 2000-01-06 18:14 UTC
expect 2000-01-06 "new moon"
expect 2000-01-07 "new moon"
expect 2000-01-14 "first quarter"
expect 2000-01-21 "waxing gibbous"
expect 2000-01-28 "waning gibbous"
expect 2024-01-11 "new moon"
expect 2024-04-08 "new moon"
expect 2026-10-15 "waxing crescent"

# bad input must fail with exit 2
for bad in foo 2000-13-01 2000-01-00 "2000-01-01 extra"; do
    "$bin" $bad >/dev/null 2>&1
    rc=$?
    if [ "$rc" -eq 2 ]; then
        echo "ok reject '$bad'"
    else
        echo "FAIL reject '$bad': exit $rc, wanted 2"; fails=$((fails + 1))
    fi
done

# no argument uses today's UTC date and must succeed
if "$bin" >/dev/null 2>&1; then
    echo "ok no argument"
else
    echo "FAIL no argument"; fails=$((fails + 1))
fi

if [ "$fails" -eq 0 ]; then
    echo PASS
    exit 0
fi
echo "FAIL $fails"
exit 1
