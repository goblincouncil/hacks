#!/usr/bin/env python3
"""rotogif: a rotozoomer that writes a looping animated GIF with a
hand-rolled LZW encoder, and hides its own source in the GIF comment.

usage:
  python3 rotogif.py [out.gif]             render the animation
  python3 rotogif.py --extract in.gif [f]  pull the hidden source back out
"""
import math
import struct
import sys

W = H = 128
FRAMES = 32
DELAY = 4          # hundredths of a second per frame
TURN = 1.0         # turns per loop; a whole number makes the loop seamless


def palette():
    pal = []
    for i in range(256):
        t = i / 256 * 2 * math.pi
        pal.append(tuple(int(127.5 + 127.5 * math.sin(t + k * 2.0944))
                         for k in range(3)))
    return pal


def params(f):
    """Motion at frame f: rotation times zoom, pan, colour shift. Every
    term completes whole cycles over FRAMES frames, so the state at frame
    FRAMES lands back on frame 0 (the colour shift modulo 256)."""
    a = 2 * math.pi * TURN * f / FRAMES
    z = 0.8 + 0.4 * math.sin(a)
    return (math.cos(a) * z, math.sin(a) * z,
            96 * math.cos(a), 96 * math.sin(2 * a), 8 * f * TURN)


def render(f):
    """One frame as 8-bit palette indices: a rotated, zoomed XOR texture.
    The frame index wraps before any float maths: cos(2*pi) is not exactly
    1, and the floors below would turn that into thousands of bad pixels."""
    c, s, ox, oy, shift = params(f % FRAMES)
    shift = int(shift)
    px = bytearray(W * H)
    i = 0
    for y in range(H):
        dy = y - H / 2
        for x in range(W):
            dx = x - W / 2
            u = math.floor(ox + dx * c - dy * s)
            v = math.floor(oy + dx * s + dy * c)
            px[i] = ((u ^ v) + shift) & 255
            i += 1
    return bytes(px)


def lzw(data, mcs=8):
    """GIF-flavoured LZW: variable code width, LSB-first, clear at 4096."""
    clear, eoi = 1 << mcs, (1 << mcs) + 1
    buf, acc, n = bytearray(), 0, 0
    size, nxt, table = mcs + 1, eoi + 1, {}

    def put(code):
        nonlocal acc, n
        acc |= code << n
        n += size
        while n >= 8:
            buf.append(acc & 255)
            acc >>= 8
            n -= 8

    put(clear)
    cur = data[0]
    for k in data[1:]:
        key = (cur, k)
        if key in table:
            cur = table[key]
            continue
        put(cur)
        if nxt == 4096:
            put(clear)
            size, nxt, table = mcs + 1, eoi + 1, {}
        else:
            table[key] = nxt
            nxt += 1
            if nxt > (1 << size) and size < 12:
                size += 1
        cur = k
    put(cur)
    put(eoi)
    if n:
        buf.append(acc & 255)
    return bytes(buf)


def blocks(data):
    out = bytearray()
    for i in range(0, len(data), 255):
        chunk = data[i:i + 255]
        out += bytes((len(chunk),)) + chunk
    return bytes(out) + b'\x00'


def subblocks(g, i):
    data = bytearray()
    while g[i]:
        data += g[i + 1:i + 1 + g[i]]
        i += 1 + g[i]
    return bytes(data), i + 1


def make_gif(comment):
    out = bytearray(b'GIF89a')
    out += struct.pack('<HHBBB', W, H, 0xF7, 0, 0)
    for rgb in palette():
        out += bytes(rgb)
    out += b'\x21\xff\x0bNETSCAPE2.0\x03\x01\x00\x00\x00'
    out += b'\x21\xfe' + blocks(comment)
    for f in range(FRAMES):
        out += b'\x21\xf9\x04\x04' + struct.pack('<H', DELAY) + b'\x00\x00'
        out += b'\x2c' + struct.pack('<HHHHB', 0, 0, W, H, 0)
        out += b'\x08' + blocks(lzw(render(f)))
    return bytes(out + b'\x3b')


def comment_of(g):
    if g[:6] not in (b'GIF87a', b'GIF89a'):
        raise ValueError('not a GIF')
    i = 13
    if g[10] & 0x80:
        i += 3 << ((g[10] & 7) + 1)
    while g[i] != 0x3b:
        if g[i] == 0x2c:
            flags = g[i + 9]
            i += 10
            if flags & 0x80:
                i += 3 << ((flags & 7) + 1)
            _, i = subblocks(g, i + 1)
        elif g[i] == 0x21:
            label = g[i + 1]
            data, i = subblocks(g, i + 2)
            if label == 0xfe:
                return data
        else:
            raise ValueError('bad block at %d' % i)
    raise ValueError('no comment block')


def main(argv):
    if argv[:1] == ['--extract']:
        if len(argv) < 2:
            sys.exit('usage: rotogif.py --extract in.gif [out.py]')
        with open(argv[1], 'rb') as fh:
            src = comment_of(fh.read())
        if len(argv) > 2:
            with open(argv[2], 'wb') as fh:
                fh.write(src)
        else:
            sys.stdout.buffer.write(src)
        return
    with open(__file__, 'rb') as fh:
        me = fh.read()
    path = argv[0] if argv else 'rotogif.gif'
    gif = make_gif(me)
    with open(path, 'wb') as fh:
        fh.write(gif)
    print('%s: %d frames, %dx%d, %d bytes' % (path, FRAMES, W, H, len(gif)))


if __name__ == '__main__':
    main(sys.argv[1:])
