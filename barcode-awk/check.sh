#!/bin/sh
# check.sh: exits 0 only if barcode.awk really makes valid Code 128.
# 1. fixed and random strings: awk output must decode back with decode.py
#    (start, checksum and stop verified) and match ref.py byte for byte.
# 2. bad input must be refused, and a damaged barcode must not decode.
# 3. sabotaged copies of barcode.awk must be caught.
set -u
here=$(cd "$(dirname "$0")" && pwd)
cd "$here" || exit 1
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
fail=0
ok() { echo "ok   $*"; }
no() { echo "FAIL $*"; fail=1; }

for t in awk python3 sed cmp; do
  command -v "$t" >/dev/null 2>&1 || { echo "FAIL missing $t"; exit 1; }
done

scan() { python3 -B decode.py "$1" 2>/dev/null; }

# test one string with a given awk script; returns 0 if good
one() {
  script=$1 s=$2 sc=$3 hh=$4
  printf '%s\n' "$s" | awk -v scale="$sc" -v h="$hh" -f "$script" > "$tmp/a.pbm" 2>/dev/null || return 1
  python3 -B ref.py "$s" "$sc" "$hh" > "$tmp/b.pbm" || return 1
  cmp -s "$tmp/a.pbm" "$tmp/b.pbm" || return 1
  got=$(scan "$tmp/a.pbm") || return 1
  [ "$got" = "$s" ]
}

# strings to try: fixed ones covering every printable character, then random
python3 - > "$tmp/cases" <<'EOF'
import random
random.seed(19)
pr = "".join(chr(i) for i in range(32, 127))
cases = ["goblincouncil", "a", "Hello, World!", "0123456789",
         pr[1:48], pr[48:], "x" + pr[:40], "~~~", "a b c"]
for _ in range(40):
    n = random.randint(1, 30)
    s = "".join(random.choice(pr) for _ in range(n)).strip()
    if s:
        cases.append(s)
for c in cases:
    print(c)
EOF

n=0 bad=0
while IFS= read -r s; do
  n=$((n + 1))
  case $((n % 3)) in 0) sc=1 hh=30 ;; 1) sc=2 hh=60 ;; 2) sc=3 hh=45 ;; esac
  if ! one barcode.awk "$s" "$sc" "$hh"; then bad=$((bad + 1)); echo "  miss: [$s]"; fi
done < "$tmp/cases"
if [ "$bad" -eq 0 ] && [ "$n" -ge 40 ]; then ok "$n strings decode back and match ref.py"
else no "$bad of $n strings failed"; fi

# every printable character appears in the fixed cases
python3 - "$tmp/cases" <<'EOF' && ok "cases cover all 95 printable characters" || no "coverage"
import sys
seen = set(open(sys.argv[1]).read()) - {"\n"}
sys.exit(0 if seen >= {chr(i) for i in range(32, 127)} else 1)
EOF

# the headline: goblincouncil, default settings
echo goblincouncil | awk -f barcode.awk > "$tmp/g.pbm"
[ "$(scan "$tmp/g.pbm")" = goblincouncil ] && ok "default goblincouncil decodes" || no "default goblincouncil"
[ "$(sed -n 3p "$tmp/g.pbm")" = "396 80" ] && ok "goblincouncil is 396x80" || no "size $(sed -n 3p "$tmp/g.pbm")"

# the decoder is not a yes-machine: flip one bar module in every row
awk 'NR <= 3 { print; next } { print substr($0, 1, 22) (substr($0, 23, 1) == "1" ? "0" : "1") substr($0, 24) }' \
  "$tmp/g.pbm" > "$tmp/d.pbm"
if cmp -s "$tmp/g.pbm" "$tmp/d.pbm"; then no "damage did not change the image"
elif scan "$tmp/d.pbm" >/dev/null; then no "damaged barcode still decoded"
else ok "damaged barcode refused by decoder"; fi

# refusals: empty line, non-ASCII, tab, no input at all
for s in "" "$(printf 'caf\303\251')" "$(printf 'a\tb')"; do
  if printf '%s\n' "$s" | awk -f barcode.awk > /dev/null 2>&1; then no "accepted bad input [$s]"
  else ok "refused [$s]"; fi
done
if printf '' | awk -f barcode.awk > /dev/null 2>&1; then no "accepted no input"
else ok "refused no input"; fi

# sabotage: each copy breaks one thing and must fail at least one string
sab() {
  name=$1 expr=$2
  sed "$expr" barcode.awk > "$tmp/s.awk"
  if cmp -s barcode.awk "$tmp/s.awk"; then no "sabotage $name did not change the script"; return; fi
  caught=0
  for s in goblincouncil "Hello, World!" "~{|}" "zz top 99"; do
    one "$tmp/s.awk" "$s" 2 60 || { caught=1; break; }
  done
  [ "$caught" -eq 1 ] && ok "sabotage caught: $name" || no "sabotage missed: $name"
}
sab "checksum weight off by one" 's/sum += v\[k\] \* (i)/sum += v[k] * (i + 1)/'
sab "checksum mod 101"           's/sum % 103/sum % 101/'
sab "code set A start"           's/sum = 104; v\[1\] = 104/sum = 103; v[1] = 103/'
sab "one table entry swapped"    's/212222 222122/222122 212222/'
sab "no quiet zone"              's/row = "0000000000"$/row = ""/'

if [ "$fail" -eq 0 ]; then echo PASS; exit 0; fi
echo FAIL; exit 1
