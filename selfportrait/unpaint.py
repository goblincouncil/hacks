# Reads the program back out of a selfportrait PNG (filter type 0 only).
import sys, zlib

data = open(sys.argv[1], "rb").read()
assert data[:8] == b"\x89PNG\r\n\x1a\n", "not a PNG"
pos, idat, kw, kh = 8, b"", 1, 1
while pos < len(data):
    n = int.from_bytes(data[pos:pos + 4], "big")
    t, d = data[pos + 4:pos + 8], data[pos + 8:pos + 8 + n]
    pos += 12 + n
    if t == b"IHDR":
        w, h = int.from_bytes(d[:4], "big"), int.from_bytes(d[4:8], "big")
    elif t == b"tEXt" and d.startswith(b"scale\0"):
        kw, kh = map(int, d[6:].split(b"x"))
    elif t == b"IDAT":
        idat += d
raw = zlib.decompress(idat)
stride = w + 1
lines = []
for y in range(0, h, kh):
    row = raw[y * stride + 1:(y + 1) * stride]
    lines.append(bytes(row[x] for x in range(0, w, kw)).rstrip(b"\0"))
sys.stdout.buffer.write(b"\n".join(lines) + b"\n")
