#!/bin/sh
# shpng: write a PNG image to stdout.
#   sh shpng.sh WIDTH HEIGHT > out.png
# The picture is a fixed test pattern: a red ramp across, a green ramp down,
# and a blue checker of 8-pixel squares. Pixels are 8-bit RGB, every row uses
# filter 0, and the zlib stream holds stored (uncompressed) deflate blocks.
# CRC-32 and Adler-32 are computed here in shell arithmetic, byte by byte.
set -eu

valid() {
  case "$1" in ''|*[!0-9]*) return 1 ;; esac
  [ "$1" -ge 1 ]
}
if ! valid "${1:-}" || ! valid "${2:-}"; then
  echo "usage: sh shpng.sh WIDTH HEIGHT > out.png" >&2
  exit 2
fi
W=$1
H=$2
WX=$((W - 1)); if [ "$WX" -lt 1 ]; then WX=1; fi
HY=$((H - 1)); if [ "$HY" -lt 1 ]; then HY=1; fi

# E<n> holds the printf escape for byte n, built once so that writing a
# byte needs no subshell.
i=0
while [ "$i" -lt 256 ]; do
  eval "E$i=\\\\$(printf '%03o' "$i")"
  i=$((i + 1))
done

out() { eval "printf \"\$E$1\""; }
ob() { out "$1"; feed "$1"; }
dat() { out "$1"; feed "$1"; adl "$1"; }

crc=4294967295
feed() {
  c=$((crc ^ $1))
  n=0
  while [ "$n" -lt 8 ]; do
    if [ $((c & 1)) -eq 1 ]; then
      c=$(((c >> 1) ^ 0xEDB88320))
    else
      c=$((c >> 1))
    fi
    n=$((n + 1))
  done
  crc=$c
}

s1=1
s2=0
adl() {
  s1=$(((s1 + $1) % 65521))
  s2=$(((s2 + s1) % 65521))
}

u32() {
  q=24
  while [ "$q" -ge 0 ]; do
    v=$((($1 >> q) & 255))
    out "$v"
    if [ "$2" = 1 ]; then feed "$v"; fi
    q=$((q - 8))
  done
}

begin() {
  u32 "$1" 0
  crc=4294967295
  ob "$2"; ob "$3"; ob "$4"; ob "$5"
}

finish() { u32 $((crc ^ 4294967295)) 0; }

pixel() {
  case "$3" in
    0) pv=$(($1 * 255 / WX)) ;;
    1) pv=$(($2 * 255 / HY)) ;;
    *) pv=$(( (($1 / 8 + $2 / 8) % 2) * 255 )) ;;
  esac
}

block() {
  if [ "$1" -gt 65535 ]; then rem=65535; fin=0; else rem=$1; fin=1; fi
  ob "$fin"
  ob $((rem & 255)); ob $((rem >> 8))
  nl=$((rem ^ 65535))
  ob $((nl & 255)); ob $((nl >> 8))
}

out 137; out 80; out 78; out 71; out 13; out 10; out 26; out 10

begin 13 73 72 68 82
u32 "$W" 1
u32 "$H" 1
ob 8; ob 2; ob 0; ob 0; ob 0
finish

ROW=$((1 + 3 * W))
N=$((H * ROW))
BLOCKS=$(((N + 65534) / 65535))
begin $((2 + 5 * BLOCKS + N + 4)) 73 68 65 84
ob 120; ob 1
i=0
while [ "$i" -lt "$N" ]; do
  if [ $((i % 65535)) -eq 0 ]; then block $((N - i)); fi
  r=$((i % ROW))
  if [ "$r" -eq 0 ]; then
    dat 0
  else
    p=$((r - 1))
    pixel $((p / 3)) $((i / ROW)) $((p % 3))
    dat "$pv"
  fi
  i=$((i + 1))
done
u32 $((s2 * 65536 + s1)) 1
finish

begin 0 73 69 78 68
finish
