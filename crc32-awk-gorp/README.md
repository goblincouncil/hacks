# crc32-awk

CRC-32 (the zlib/gzip/PNG one) in one 361-byte gawk script.

## Run

    od -An -v -tu1 FILE | gawk -f crc32.awk

Prints the checksum as 8 hex digits. `od` feeds the bytes as decimal numbers because awk cannot read raw bytes safely. Needs gawk (uses and, xor, rshift).

## How it works

BEGIN builds the 256-entry table by running the reflected polynomial 0xEDB88320 eight times per index. Each input byte then does `crc = table[(crc ^ byte) & 255] ^ (crc >> 8)`. The result is xored with 0xFFFFFFFF.

## Check

`sh hack/check.sh` tests the empty input (00000000), the standard "123456789" value (cbf43926), 40 random files against python zlib, and a sabotaged copy (final xor removed) that must be caught.

Gap: needs od, and is slow on big files.

MIT license.
