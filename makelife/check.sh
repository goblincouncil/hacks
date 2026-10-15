#!/bin/sh
# makelife check: life.mk must agree byte for byte with an independent
# Python Game of Life, reject bad input, and do it without starting a shell.
cd "$(dirname "$0")" || exit 1
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fail=0; pass=0
ok() { pass=$((pass+1)); echo "ok   $1"; }
bad() { fail=$((fail+1)); echo "FAIL $1"; }

command -v make >/dev/null || { echo "FAIL no make"; exit 1; }
command -v python3 >/dev/null || { echo "FAIL no python3"; exit 1; }

# 1. every board, many generations, against the twin. SHELL=/bin/false
#    proves no recipe or $(shell) ever runs: if one did, make would fail.
for b in boards/*.txt; do
  make -s -f life.mk SHELL=/bin/false BOARD="$b" GENS=40 > "$T/mk" 2>"$T/err" \
    && python3 twin.py "$b" 40 > "$T/py" && cmp -s "$T/mk" "$T/py" \
    && test ! -s "$T/err" && ok "$b matches twin for 40 generations" \
    || bad "$b differs from twin"
done

# 2. known facts, not just agreement: a glider returns home after 32 steps
#    on an 8x8 torus, a blinker has period 2, population stays 5.
make -s -f life.mk BOARD=boards/glider.txt GENS=32 > "$T/g"
sed -n '2,9p' "$T/g" > "$T/g0"; tail -n 9 "$T/g" | head -n 8 > "$T/g32"
cmp -s "$T/g0" "$T/g32" && cmp -s "$T/g0" boards/glider.txt \
  && ok "glider wraps the torus and comes home at generation 32" \
  || bad "glider did not come home"
grep -c 'population 5$' "$T/g" | grep -qx 33 && ok "glider keeps population 5" \
  || bad "glider population drifted"
make -s -f life.mk BOARD=boards/blinker.txt GENS=2 > "$T/k"
sed -n '2,6p' "$T/k" > "$T/k0"; sed -n '9,13p' "$T/k" > "$T/k1"; sed -n '16,20p' "$T/k" > "$T/k2"
! cmp -s "$T/k0" "$T/k1" && cmp -s "$T/k0" "$T/k2" && grep -qx '.###.' "$T/k1" \
  && ok "blinker flips and flips back" || bad "blinker wrong"

# 3. bad input must stop make with exit 2 and a makelife message
printf '..#\n.#\n' > "$T/ragged"; printf '..x\n...\n' > "$T/char"; : > "$T/empty"
for case in "BOARD=$T/ragged" "BOARD=$T/char" "BOARD=$T/empty" "BOARD=$T/missing" \
            GENS=abc GENS=-1 GENS=1.5 GENS=; do
  make -s -f life.mk "$case" > /dev/null 2> "$T/e"; rc=$?
  [ $rc -eq 2 ] && grep -q 'makelife:' "$T/e" && ok "rejects $case" || bad "accepted $case (rc=$rc)"
done

# 4. sabotage: break the birth rule and the check must notice
sed 's/filter 3,\$(words/filter 3 4,$(words/' life.mk > "$T/broken.mk"
if cmp -s life.mk "$T/broken.mk"; then bad "sabotage sed did not apply"
else
  make -s -f "$T/broken.mk" BOARD=boards/soup.txt GENS=10 > "$T/mk" 2>/dev/null
  python3 twin.py boards/soup.txt 10 > "$T/py"
  cmp -s "$T/mk" "$T/py" && bad "sabotaged rule went unnoticed" || ok "sabotaged rule is caught"
fi

echo "$pass ok, $fail failed"
[ $fail -eq 0 ] && [ $pass -gt 0 ] && echo PASS && exit 0
echo FAIL; exit 1
