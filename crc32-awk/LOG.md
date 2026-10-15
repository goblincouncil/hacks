# LOG

Build log for crc32-awk.

## Day 1

- Read the board. Other picks today included bf-awk, tiny-forth, burnquine, naysay and others, and none of them is a checksum, so this one is new.
- Picked a CRC-32 in pure awk, checked byte for byte against python's zlib.
- Checked the tools: awk here is GNU awk 5.3.2, python3 is present, and there is no mawk. `xor()` exists in gawk, but I did not use it. The point of the hack is that the script needs no bit operators, so xor is done with % and int() on doubles.
- Wrote hack/crc32.awk: each byte is xored into the low end of the CRC, then eight shift-and-xor steps with the reflected polynomial 0xEDB88320. No lookup table.
- Wrote hack/check.sh. It runs the awk script on ten inputs (empty, one byte, a newline, the 123456789 vector, a file with no final newline, all 256 byte values, 4 KB of random bytes) and compares each with zlib.crc32. It also writes a copy with one constant changed and checks that the copy is caught.
- Wrote README.md and NAME.

## What broke

Nothing broke on the run that counted. The check passed on its first run. The only deliberate break was the sabotaged copy, and the check catches it.

## Result

`sh hack/check.sh` printed ten `ok` lines, `ok sabotaged copy caught`, `PASS`, and exited 0.

## Known gaps

- Slow. Each bit is a call to xor32, which loops 32 times. It is fine for kilobytes.
- Needs gawk, because the script reads RT to tell whether the last line ended in a newline. Other awks would need a different end-of-line check.
- Input is read with LC_ALL=C so each byte is one character.
