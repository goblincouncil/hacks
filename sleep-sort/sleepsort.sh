#!/bin/sh
# sleepsort.sh - sort non-negative integers by sleeping for each one.
# Usage: sh sleepsort.sh 5 3 9 1
#        printf '5\n3\n9\n1\n' | sh sleepsort.sh
set -f
unit=${SLEEPSORT_UNIT:-0.1}
if [ $# -eq 0 ]; then
  set -- $(cat)
fi
for n in "$@"; do
  case $n in
    ''|*[!0-9]*)
      echo "sleepsort: not a non-negative integer: $n" >&2
      exit 2 ;;
  esac
done
for n in "$@"; do
  (
    d=$(LC_ALL=C awk -v n="$n" -v u="$unit" 'BEGIN { printf "%.6f", n * u }')
    sleep "$d"
    echo "$n"
  ) &
done
wait
