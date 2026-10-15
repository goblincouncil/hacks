#!/bin/sh
# Test for sandfall. Exits 0 only if the sim conserves grains, leaves the pile
# settled, is deterministic per seed, and a sabotaged copy gets caught.
cd "$(dirname "$0")" || exit 1
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

cat > "$tmp/verify.awk" <<'AWK'
{ lines[NR] = $0 }
END {
	if (NR != H + 1) { print "bad line count " NR; exit 1 }
	for (y = 0; y < H; y++) {
		s = lines[y + 1]
		if (length(s) != W) { print "bad width, row " y; exit 1 }
		for (x = 0; x < W; x++) {
			c = substr(s, x + 1, 1)
			if (c != "#" && c != ".") { print "bad char at " y "," x; exit 1 }
			g[y, x] = (c == "#")
			cnt += g[y, x]
		}
	}
	if (lines[H + 1] !~ /^drops=[0-9]+$/) { print "bad drops line"; exit 1 }
	drops = substr(lines[H + 1], 7) + 0
	if (drops > N) { print "drops above N"; exit 1 }
	if (cnt != drops) { print "grains " cnt " != drops " drops; exit 1 }
	for (y = 0; y < H - 1; y++)
		for (x = 0; x < W; x++) {
			if (!g[y, x]) continue
			if (!g[y + 1, x]) { print "unsettled grain at " y "," x; exit 1 }
			for (d = -1; d <= 1; d += 2) {
				nx = x + d
				if (nx >= 0 && nx < W && !g[y + 1, nx]) { print "grain can still slide at " y "," x; exit 1 }
			}
		}
}
AWK

run() { awk -v W="$1" -v H="$2" -v N="$3" -v SEED="$4" -f "$5"; }
check_file() { awk -v W="$1" -v H="$2" -v N="$3" -f "$tmp/verify.awk" "$4"; }

for case in "12 8 30 3" "7 5 20 1" "1 4 3 9" "20 10 60 42" "12 8 0 5" "30 12 200 7"; do
	set -- $case
	run "$1" "$2" "$3" "$4" sandfall.awk > "$tmp/out" || fail "awk error on $case"
	check_file "$1" "$2" "$3" "$tmp/out" > "$tmp/msg" || { cat "$tmp/msg"; fail "invariant broke on $case"; }
	run "$1" "$2" "$3" "$4" sandfall.awk > "$tmp/out2" || fail "awk error on rerun $case"
	cmp -s "$tmp/out" "$tmp/out2" || fail "not deterministic on $case"
	echo "ok $case"
done

distinct=$(for s in 1 2 3 4 5; do run 12 8 30 $s sandfall.awk | cksum; done | sort -u | wc -l)
[ "$distinct" -ge 2 ] || fail "seeds do not change the pile"
echo "ok seeds vary ($distinct distinct)"

sed 's/g\[y + 1, x\] = 1; g\[y, x\] = 0; moved++/g[y, x] = 0; moved++/' sandfall.awk > "$tmp/bad.awk"
cmp -s sandfall.awk "$tmp/bad.awk" && fail "sabotage did not apply"
awk -v W=12 -v H=8 -v N=30 -v SEED=3 -f "$tmp/bad.awk" > "$tmp/bad.out" || fail "sabotaged copy crashed"
if check_file 12 8 30 "$tmp/bad.out" >/dev/null 2>&1; then fail "sabotaged copy passed"; fi
echo "ok sabotaged copy caught"
echo PASS
exit 0
