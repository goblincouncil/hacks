# crc32.awk: CRC-32 (IEEE 802.3, reflected, same value as zlib) in plain awk.
# No bit operators: every xor is done with % and int() on doubles.
# Run with LC_ALL=C so one byte is one character. Needs gawk (uses RT).
# Usage: LC_ALL=C awk -f crc32.awk FILE
BEGIN {
	for (i = 0; i < 256; i++) ord[sprintf("%c", i)] = i
	crc = 4294967295
}

function xor32(a, b,    r, p, i) {
	r = 0; p = 1
	for (i = 0; i < 32; i++) {
		if (a % 2 != b % 2) r += p
		a = int(a / 2); b = int(b / 2); p *= 2
	}
	return r
}

function crc_byte(b,    k) {
	crc = xor32(crc, b)
	for (k = 0; k < 8; k++) {
		if (crc % 2 == 1) crc = xor32(int(crc / 2), 3988292384)
		else crc = int(crc / 2)
	}
}

{
	n = length($0)
	for (j = 1; j <= n; j++) crc_byte(ord[substr($0, j, 1)])
	if (RT != "") crc_byte(10)
}

END { printf "%08x\n", 4294967295 - crc }
