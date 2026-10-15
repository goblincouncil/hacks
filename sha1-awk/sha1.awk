# sha1.awk: SHA-1 of a byte stream given as decimal bytes (od -An -v -tu1).
# usage: od -An -v -tu1 FILE | gawk -f sha1.awk
function rol(x, n) { return or(and(lshift(x, n), 0xFFFFFFFF), rshift(x, 32 - n)) }
function add(a, b) { return and(a + b, 0xFFFFFFFF) }
function block(off,    t, a, b, c, d, e, f, k, tmp) {
  for (t = 0; t < 16; t++)
    w[t] = m[off+4*t]*16777216 + m[off+4*t+1]*65536 + m[off+4*t+2]*256 + m[off+4*t+3]
  for (t = 16; t < 80; t++)
    w[t] = rol(xor(xor(w[t-3], w[t-8]), xor(w[t-14], w[t-16])), 1)
  a = h0; b = h1; c = h2; d = h3; e = h4
  for (t = 0; t < 80; t++) {
    if (t < 20)      { f = or(and(b, c), and(xor(b, 0xFFFFFFFF), d)); k = 0x5A827999 }
    else if (t < 40) { f = xor(xor(b, c), d); k = 0x6ED9EBA1 }
    else if (t < 60) { f = or(or(and(b, c), and(b, d)), and(c, d)); k = 0x8F1BBCDC }
    else             { f = xor(xor(b, c), d); k = 0xCA62C1D6 }
    tmp = add(add(add(rol(a, 5), f), add(e, k)), w[t])
    e = d; d = c; c = rol(b, 30); b = a; a = tmp
  }
  h0 = add(h0, a); h1 = add(h1, b); h2 = add(h2, c); h3 = add(h3, d); h4 = add(h4, e)
}
BEGIN { h0 = 0x67452301; h1 = 0xEFCDAB89; h2 = 0x98BADCFE; h3 = 0x10325476; h4 = 0xC3D2E1F0 }
{ for (i = 1; i <= NF; i++) m[n++] = $i }
END {
  len = n
  m[n++] = 128
  while (n % 64 != 56) m[n++] = 0
  bits = len * 8
  for (i = 7; i >= 0; i--) { m[n+i] = bits % 256; bits = int(bits / 256) }
  n += 8
  for (o = 0; o < n; o += 64) block(o)
  printf "%08x%08x%08x%08x%08x\n", h0, h1, h2, h3, h4
}
