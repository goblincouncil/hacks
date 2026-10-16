# Independent PNG reader for shpng. Walks the chunks, checks every CRC with
# zlib.crc32, inflates the IDAT stream (zlib checks Adler-32), and compares the
# pixels with a pattern written here again, not taken from the encoder.
import struct
import sys
import zlib

SIG = bytes([137, 80, 78, 71, 13, 10, 26, 10])


def fail(msg):
    print("decode: " + msg, file=sys.stderr)
    sys.exit(1)


def pattern(x, y, w, h, ch):
    if ch == 0:
        return x * 255 // max(w - 1, 1)
    if ch == 1:
        return y * 255 // max(h - 1, 1)
    return 255 if (x // 8 + y // 8) % 2 else 0


def main():
    if len(sys.argv) != 4:
        fail("usage: decode.py FILE WIDTH HEIGHT")
    path, want_w, want_h = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    with open(path, "rb") as f:
        data = f.read()
    if data[:8] != SIG:
        fail("bad signature")
    pos = 8
    ihdr = None
    idat = []
    ended = False
    while pos < len(data) and not ended:
        if pos + 12 > len(data):
            fail("truncated chunk header")
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        kind = data[pos + 4:pos + 8]
        if pos + 12 + length > len(data):
            fail("truncated chunk " + kind.decode("ascii", "replace"))
        body = data[pos + 8:pos + 8 + length]
        (crc,) = struct.unpack(">I", data[pos + 8 + length:pos + 12 + length])
        if zlib.crc32(kind + body) != crc:
            fail("CRC mismatch in " + kind.decode("ascii", "replace"))
        if kind == b"IHDR":
            ihdr = struct.unpack(">IIBBBBB", body)
        elif kind == b"IDAT":
            idat.append(body)
        elif kind == b"IEND":
            ended = True
        pos += 12 + length
    if not ended or pos != len(data):
        fail("no IEND at end of file")
    if ihdr is None or not idat:
        fail("missing IHDR or IDAT")
    width, height, depth, ctype, comp, filt, inter = ihdr
    if (width, height) != (want_w, want_h):
        fail("size %dx%d, wanted %dx%d" % (width, height, want_w, want_h))
    if (depth, ctype, comp, filt, inter) != (8, 2, 0, 0, 0):
        fail("unexpected IHDR fields %r" % (ihdr,))
    try:
        raw = zlib.decompress(b"".join(idat))
    except zlib.error as e:
        fail("zlib: %s" % e)
    expect = bytearray()
    for y in range(height):
        expect.append(0)
        for x in range(width):
            for ch in range(3):
                expect.append(pattern(x, y, width, height, ch))
    if len(raw) != len(expect):
        fail("length %d, wanted %d" % (len(raw), len(expect)))
    if raw != bytes(expect):
        k = next(i for i in range(len(raw)) if raw[i] != expect[i])
        fail("byte %d is %d, wanted %d" % (k, raw[k], expect[k]))
    print("ok %dx%d, %d raw bytes, %d IDAT chunk(s)" % (width, height, len(raw), len(idat)))


main()
