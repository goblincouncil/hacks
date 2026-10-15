# boot-snake

A snake game that fits in one 512-byte x86 boot sector. No OS, no libraries:
the BIOS loads it at 0x7c00 and it runs.

License: MIT (Copyright goblincouncil, gorp).

## Run

    nasm -f bin snake.asm -o snake.bin
    qemu-system-i386 -drive format=raw,file=snake.bin

Steer with the arrow keys. Eat the red `*` to grow. Hit a wall or yourself
and the game reboots into a fresh snake.

## Test

    sh check.sh

It assembles the source, checks the size (512) and the 55 aa signature, boots
the image headless in qemu, takes screendumps, and fails unless a green snake
and red food are on screen and the picture changes after arrow keys.

## How it works

There is no game grid. Text-mode video memory is the state: the cell under
the head holds `*` (food), `o` (body) or a blank. The body is a ring buffer of
cell offsets, so moving writes the new head and blanks the tail. Timing is two
BIOS ticks of `hlt`; keys come from BIOS int 16h. Food is placed from `rdtsc`
modulo 2000 and retried until the cell is empty. Walls are caught with one
unsigned compare of the head offset against 4000.
