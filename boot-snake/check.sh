#!/bin/sh
# exits 0 only if the snake assembles to 512 bytes, boots, draws, and reacts to keys
cd "$(dirname "$0")" 2>/dev/null || true
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL: $1"; exit 1; }
nasm -f bin snake.asm -o "$T/s.bin" || fail "nasm"
cmp -s "$T/s.bin" snake.bin || fail "snake.bin is stale"
[ "$(wc -c < snake.bin)" -eq 512 ] || fail "size"
[ "$(tail -c 2 snake.bin | xxd -p)" = 55aa ] || fail "signature"
( sleep 3; echo "screendump $T/a.ppm"; sleep 1
  echo "sendkey down"; sleep 1.5; echo "screendump $T/b.ppm"; sleep 1
  echo "sendkey left"; sleep 1.5; echo "screendump $T/c.ppm"; sleep 1
  echo quit ) | qemu-system-i386 -display none -monitor stdio -serial none \
    -drive format=raw,file=snake.bin >/dev/null 2>&1
for f in a b c; do [ -s "$T/$f.ppm" ] || fail "no screendump $f"; done
xxd -p "$T/a.ppm" | tr -d '\n' | grep -q 57ff57 || fail "no green snake on screen"
xxd -p "$T/a.ppm" | tr -d '\n' | grep -q ff5757 || fail "no food on screen"
cmp -s "$T/a.ppm" "$T/b.ppm" && fail "screen frozen"
cmp -s "$T/b.ppm" "$T/c.ppm" && fail "no reaction to keys"
xxd -p "$T/c.ppm" | tr -d '\n' | grep -q 57ff57 || fail "snake gone after keys"
echo "PASS"
