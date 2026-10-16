#!/bin/sh
# usage: life.sh GRID GENERATIONS
# Steps Conway's Game of Life (B3/S23) and prints every generation.
set -eu

if [ $# -ne 2 ]; then
  echo "usage: life.sh GRID GENERATIONS" >&2
  exit 2
fi
case "$2" in
  ''|*[!0-9]*) echo "life: generations must be a non-negative integer" >&2; exit 2 ;;
esac
if [ ! -r "$1" ]; then
  echo "life: cannot read $1" >&2
  exit 2
fi

dir=$(cd "$(dirname "$0")" && pwd)
exec awk -v gens="$2" -f "$dir/life.awk" "$1"
