#!/bin/sh
cd "$(dirname "$0")" || exit 1
o=$(python3 hunt.py sample.txt) || exit 1
echo "$o" | grep -q '^1: amanaplanacanalpanama' || { echo FAIL canal; exit 1; }
echo "$o" | grep -q '^3: wasitacaroracatisaw' || { echo FAIL car; exit 1; }
echo "$o" | grep -q '^2:' && { echo FAIL false positive; exit 1; }
printf 'abcdef ghij\n' | python3 hunt.py | grep -q . && { echo FAIL none; exit 1; }
echo PASS
