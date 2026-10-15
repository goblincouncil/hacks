#!/bin/sh
# Exits 0 only if the wrong-way route is deterministic and every step lands off the map.
set -e
H=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
python3 "$H/wrongway.py" 4,4 16,16 > "$T/a.txt"
python3 "$H/wrongway.py" 4,4 16,16 > "$T/b.txt"
cmp "$T/a.txt" "$T/b.txt"
python3 "$H/check_route.py" "$H" "$T/a.txt"
echo PASS
