# crc32-awk

A CRC-32 checksum in plain awk. It gives the same value as zlib, gzip and PNG
for the same bytes. The bit work is done with arithmetic and int() only, so the
script has no bitwise operators in it.

## Run

    LC_ALL=C awk -f crc32.awk FILE

It prints eight hex digits. To compare with zlib:

    python3 -c 'import sys, zlib; print("%08x" % zlib.crc32(open(sys.argv[1], "rb").read()))' FILE

The test is `sh check.sh`. It runs the awk script on a set of inputs (empty,
the standard 123456789 vector, all 256 byte values, random data, files with and
without a final newline) and compares each result with zlib. It also makes a
copy with one changed constant and checks that the copy is rejected.

## How it works

There is no lookup table. For each byte, the script xors it into the low end
of the running CRC, then does eight steps: if the low bit is set, shift right
and xor with the reflected polynomial 0xEDB88320, otherwise just shift right.
At the end the CRC is inverted and printed.

awk has no xor, so `xor32` takes two numbers, peels off their 32 bits one at a
time with % and int(), and rebuilds the result. It is slow. A few kilobytes
are fine; large files are not the point.

The script needs gawk, because it reads RT to tell whether the last line had a
newline. Input is read with LC_ALL=C so that each byte is one character.

## License

MIT.
