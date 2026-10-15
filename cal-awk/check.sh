#!/bin/sh
# compares cal.awk with python's calendar for every month 1900-2100,
# then runs a sabotaged copy that must disagree.
d=$(dirname "$0")
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
sed 's/0 3 2 5 0 3 5 1 4 6 2 4/0 3 2 5 0 3 5 1 4 6 2 5/' "$d/cal.awk" > "$tmp/bad.awk"
cmp -s "$d/cal.awk" "$tmp/bad.awk" && { echo "sabotage did not change script"; exit 1; }
cat > "$tmp/c.py" <<'PY'
import calendar, subprocess, sys
awk = sys.argv[1]
def norm(s):
    L = [x.rstrip() for x in s.rstrip("\n").split("\n")]
    L[0] = L[0].strip()
    return L
cal = calendar.TextCalendar(6)
bad = 0
for y in range(1900, 2101):
    for m in range(1, 13):
        out = subprocess.run(["awk", "-v", f"m={m}", "-v", f"y={y}", "-f", awk],
                             capture_output=True, text=True).stdout
        if norm(out) != norm(cal.formatmonth(y, m)):
            bad += 1
print(bad)
PY
good=$(python3 "$tmp/c.py" "$d/cal.awk")
sab=$(python3 "$tmp/c.py" "$tmp/bad.awk")
echo "real mismatches: $good, sabotaged mismatches: $sab"
[ "$good" = 0 ] && [ "$sab" -gt 0 ] || { echo FAIL; exit 1; }
echo PASS
