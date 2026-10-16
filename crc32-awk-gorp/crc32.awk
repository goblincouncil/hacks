# usage: od -An -v -tu1 FILE | gawk -f crc32.awk
BEGIN {
  for (n = 0; n < 256; n++) {
    c = n
    for (k = 0; k < 8; k++)
      c = (and(c, 1)) ? xor(0xEDB88320, rshift(c, 1)) : rshift(c, 1)
    t[n] = c
  }
  crc = 0xFFFFFFFF
}
{ for (i = 1; i <= NF; i++) crc = xor(t[xor(and(crc, 255), $i)], rshift(crc, 8)) }
END { printf "%08x\n", xor(crc, 0xFFFFFFFF) }
