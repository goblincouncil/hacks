#!/bin/sh
# Test for bogosort.awk. Exits 0 only if the output matches sort(1) on
# generated inputs, the edge cases hold, and a sabotaged copy gets caught.
cd "$(dirname "$0")" || exit 1
export LC_ALL=C
AWK=${AWK:-awk}
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# random small input, deterministic per seed
gen() {
    $AWK -v seed="$1" '
    BEGIN {
        srand(seed)
        alpha = "ab019 Z_"
        n = int(rand() * 8)
        for (i = 0; i < n; i++) {
            len = int(rand() * 4)
            s = ""
            for (j = 0; j < len; j++)
                s = s substr(alpha, int(rand() * length(alpha)) + 1, 1)
            print s
        }
    }'
}

# expect NAME INPUT EXPECTED, both printf formats, seed 7
expect() {
    printf "$2" > "$tmp/e_in"
    printf "$3" > "$tmp/e_exp"
    $AWK -v seed=7 -f bogosort.awk < "$tmp/e_in" > "$tmp/e_out" 2>/dev/null
    if cmp -s "$tmp/e_out" "$tmp/e_exp"; then ok "$1"; else bad "$1"; fi
}
expect "empty input" '' ''
expect "one line" 'x\n' 'x\n'
expect "letters" 'b\na\nc\n' 'a\nb\nc\n'
expect "numbers as strings" '10\n9\n' '10\n9\n'
expect "no trailing newline" 'b\na' 'a\nb\n'
expect "duplicates" 'a\nb\na\n' 'a\na\nb\n'
expect "blank lines" '\n\na\n' '\n\na\n'

printf 'b\na\n' > "$tmp/unsorted"
if $AWK -v seed=1 -v limit=0 -f bogosort.awk < "$tmp/unsorted" > /dev/null 2>&1; then
    bad "limit=0 should give up"
else
    ok "gives up at limit"
fi

# sabotaged copy: in_order only looks at the first pair
sed 's/i < n; i++/i < 2; i++/' bogosort.awk > "$tmp/sabotaged.awk"
if cmp -s bogosort.awk "$tmp/sabotaged.awk"; then
    bad "sabotage changed nothing"
else
    ok "sabotaged copy built"
fi

cases=0; mism=0; sab=0; k=1
while [ "$k" -le 200 ]; do
    gen "$k" > "$tmp/in"
    LC_ALL=C sort "$tmp/in" > "$tmp/exp"
    $AWK -v seed="$k" -f bogosort.awk < "$tmp/in" > "$tmp/out" 2>/dev/null
    cmp -s "$tmp/out" "$tmp/exp" || mism=$((mism+1))
    $AWK -v seed="$k" -f "$tmp/sabotaged.awk" < "$tmp/in" > "$tmp/sout" 2>/dev/null
    cmp -s "$tmp/sout" "$tmp/exp" || sab=$((sab+1))
    cases=$((cases+1))
    k=$((k+1))
done
if [ "$mism" -eq 0 ] && [ "$cases" -eq 200 ]; then
    ok "200 random inputs match sort(1)"
else
    bad "$mism mismatches in $cases cases"
fi
if [ "$sab" -gt 0 ]; then
    ok "sabotaged copy caught on $sab of 200 inputs"
else
    bad "sabotaged copy not caught"
fi

if [ "$fail" -eq 0 ]; then
    echo PASS
    exit 0
fi
echo FAIL
exit 1
