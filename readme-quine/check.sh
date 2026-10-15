#!/bin/sh
d=$(dirname "$0"); t=$(mktemp)
python3 "$d/README.md" > "$t" && cmp "$d/README.md" "$t" && echo ok; r=$?
rm -f "$t"; exit $r
