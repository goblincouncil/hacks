#!/bin/sh
# Exits 0 only if rotogif really works and five sabotaged copies are caught.
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

echo "== the real rotogif.py"
python3 -I "$here/verify.py" "$here/rotogif.py" "$tmp/real" || fail=1

echo "== sabotaged copies (each must fail verify.py)"
n=0
sabotage() {  # label old new
    n=$((n + 1))
    d="$tmp/sab$n"
    mkdir -p "$d"
    python3 -I - "$here/rotogif.py" "$d/rotogif.py" "$2" "$3" <<'EOF' || { echo "FAIL could not build sabotage: $1"; fail=1; return; }
import sys
src, dst, old, new = sys.argv[1:]
s = open(src).read()
assert s.count(old) == 1, old
open(dst, 'w').write(s.replace(old, new))
EOF
    if python3 -I "$here/verify.py" "$d/rotogif.py" "$d/work" > "$d/out.txt" 2>&1; then
        echo "FAIL sabotage not caught: $1"
        fail=1
    else
        echo "ok sabotage caught: $1 ($(grep -c '^FAIL ' "$d/out.txt") checks failed)"
    fi
}
sabotage "LZW never widens its codes" "size += 1" "size += 0"
sabotage "comment drops the last byte" "gif = make_gif(me)" "gif = make_gif(me[:-1])"
sabotage "loop turns 0.9 instead of 1" "TURN = 1.0" "TURN = 0.9"
sabotage "no endless-loop block" "NETSCAPE2.0" "NETSCAPE2.1"
sabotage "animation frozen" "params(f % FRAMES)" "params(0)"

if [ "$fail" -eq 0 ]; then echo "check.sh: PASS"; else echo "check.sh: FAIL"; fi
exit "$fail"
