#!/usr/bin/env python3
"""Independent checker for rotogif. It shares no GIF code with rotogif.py:
its own GIF parser and LZW decoder, plus ImageMagick as a second opinion.

usage: python3 verify.py path/to/rotogif.py workdir
Exits 0 only if every check passes.
"""
import importlib.util
import os
import shutil
import struct
import subprocess
import sys

sys.dont_write_bytecode = True
W = H = 128
FRAMES = 32
results = []


def check(name, fn):
    try:
        ok, note = fn()
    except Exception as e:  # a crash is a failed check, not a pass
        ok, note = False, '%s: %s' % (type(e).__name__, e)
    results.append(bool(ok))
    print('%s %s%s' % ('ok' if ok else 'FAIL', name,
                       ' (%s)' % note if note else ''))
    return ok


def subblocks(g, i):
    data = bytearray()
    while g[i]:
        n = g[i]
        if i + 1 + n > len(g):
            raise ValueError('truncated sub-block')
        data += g[i + 1:i + 1 + n]
        i += 1 + n
    return bytes(data), i + 1


def parse(g):
    if g[:6] != b'GIF89a':
        raise ValueError('not GIF89a')
    sw, sh, flags = struct.unpack('<HHB', g[6:11])
    i, gct = 13, None
    if flags & 0x80:
        n = 3 << ((flags & 7) + 1)
        gct, i = g[i:i + n], i + n
    info = {'size': (sw, sh), 'gct': gct, 'frames': [], 'comments': [],
            'apps': []}
    delay = None
    while g[i] != 0x3b:
        if g[i] == 0x21:
            label = g[i + 1]
            data, i = subblocks(g, i + 2)
            if label == 0xfe:
                info['comments'].append(data)
            elif label == 0xff:
                info['apps'].append(data)
            elif label == 0xf9:
                delay = data[1] | data[2] << 8
        elif g[i] == 0x2c:
            rect = struct.unpack('<HHHH', g[i + 1:i + 9])
            fl = g[i + 9]
            i += 10
            if fl & 0x80:
                raise ValueError('unexpected local palette')
            mcs = g[i]
            data, i = subblocks(g, i + 1)
            info['frames'].append({'rect': rect, 'mcs': mcs, 'data': data,
                                   'delay': delay})
            delay = None
        else:
            raise ValueError('bad block 0x%02x at %d' % (g[i], i))
    if i != len(g) - 1:
        raise ValueError('bytes after trailer')
    return info


def lzw_decode(data, mcs, npix):
    clear, eoi = 1 << mcs, (1 << mcs) + 1
    base = [bytes((k,)) for k in range(clear)] + [b'', b'']
    table, size, prev = list(base), mcs + 1, None
    val, pos, nbits = int.from_bytes(data, 'little'), 0, len(data) * 8
    out = bytearray()
    while True:
        if pos + size > nbits:
            raise ValueError('ran out of data before end code')
        code = (val >> pos) & ((1 << size) - 1)
        pos += size
        if code == clear:
            table, size, prev = list(base), mcs + 1, None
            continue
        if code == eoi:
            break
        if prev is None:
            if code >= clear:
                raise ValueError('first code %d is not a literal' % code)
            entry = table[code]
        elif code < len(table):
            entry = table[code]
            table.append(prev + entry[:1])
        elif code == len(table):
            entry = prev + prev[:1]
            table.append(entry)
        else:
            raise ValueError('code %d past table end %d' % (code, len(table)))
        out += entry
        if len(table) == (1 << size) and size < 12:
            size += 1
        prev = entry
    if len(out) != npix:
        raise ValueError('%d pixels, wanted %d' % (len(out), npix))
    return bytes(out)


def load(script):
    spec = importlib.util.spec_from_file_location('rotogif_under_test', script)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    script = os.path.abspath(sys.argv[1])
    work = os.path.abspath(sys.argv[2])
    os.makedirs(work, exist_ok=True)
    with open(script, 'rb') as fh:
        src = fh.read()
    gif_path = os.path.join(work, 'out.gif')
    st = {}

    def run():
        r = subprocess.run([sys.executable, '-I', script, gif_path], cwd=work,
                           capture_output=True, timeout=600)
        with open(gif_path, 'rb') as fh:
            st['gif'] = fh.read()
        return r.returncode == 0, '%d bytes' % len(st['gif'])

    def header():
        st['info'] = info = parse(st['gif'])
        return (info['size'] == (W, H) and info['gct'] is not None
                and len(info['gct']) == 768), '%dx%d' % info['size']

    if not (check('script runs and writes a GIF', run)
            and check('parses as GIF89a, 128x128, 256-colour palette', header)):
        print('FAIL')
        return 1
    info = st['info']
    frames = info['frames']

    def loops():
        return any(a[:11] == b'NETSCAPE2.0' and a[11:14] == b'\x01\x00\x00'
                   for a in info['apps']), 'loop count 0 = forever'

    def framecount():
        ok = (len(frames) == FRAMES
              and all(f['rect'] == (0, 0, W, H) for f in frames)
              and all(f['delay'] for f in frames))
        return ok, '%d frames' % len(frames)

    def decode():
        st['px'] = [lzw_decode(f['data'], f['mcs'], W * H) for f in frames]
        return True, '%d pixels' % sum(len(p) for p in st['px'])

    def matches_render():
        mod = st['mod'] = load(script)
        bad = [f for f in range(len(frames)) if mod.render(f) != st['px'][f]]
        return not bad, 'bad frames %s' % bad if bad else ''

    def imagemagick():
        tool = shutil.which('magick') or shutil.which('convert')
        r = subprocess.run([tool, gif_path, '-coalesce', '-depth', '8',
                            'rgb:-'], capture_output=True, timeout=300)
        gct = info['gct']
        lut = [gct[3 * k:3 * k + 3] for k in range(256)]
        want = b''.join(lut[p] for px in st['px'] for p in px)
        got = r.stdout
        diff = sum(got[k:k + 3] != want[k:k + 3]
                   for k in range(0, min(len(got), len(want)), 3))
        return (r.returncode == 0 and got == want,
                '%d of %d pixels agree' % (len(want) // 3 - diff,
                                          len(want) // 3))

    def animated():
        px = st['px']
        steps = [sum(a != b for a, b in zip(px[f], px[(f + 1) % len(px)]))
                 for f in range(len(px))]
        return min(steps) > 0.05 * W * H, 'smallest step %d px, wrap %d px' % (
            min(steps), steps[-1])

    def seamless():
        mod = st['mod']
        p0, pn = mod.params(0), mod.params(mod.FRAMES)
        d = (pn[4] - p0[4]) % 256
        err = max([abs(a - b) for a, b in zip(p0[:4], pn[:4])] + [min(d, 256 - d)])
        return err < 1e-9, 'motion state at frame 32 vs 0: max error %.1e' % err

    def comment():
        c = info['comments']
        return len(c) == 1 and c[0] == src, '%d-byte comment' % (
            len(c[0]) if c else 0)

    def extract_cli():
        r = subprocess.run([sys.executable, '-I', script, '--extract',
                            gif_path], capture_output=True, timeout=60)
        return r.returncode == 0 and r.stdout == src, ''

    def rebuild():
        d = os.path.join(work, 'rebuild')
        os.makedirs(d, exist_ok=True)
        copy = os.path.join(d, 'from_gif.py')
        with open(copy, 'wb') as fh:
            fh.write(info['comments'][0])
        out = os.path.join(d, 'again.gif')
        r = subprocess.run([sys.executable, '-I', copy, out], cwd=d,
                           capture_output=True, timeout=600)
        with open(out, 'rb') as fh:
            again = fh.read()
        return r.returncode == 0 and again == st['gif'], ''

    check('loops forever (NETSCAPE2.0 block)', loops)
    check('32 full-size frames, each with a delay', framecount)
    if check('every frame decodes with the separate LZW decoder', decode):
        check('decoded pixels equal what the renderer drew', matches_render)
        check('ImageMagick decodes the same colours', imagemagick)
        check('every step changes the picture, including 31 -> 0', animated)
    check('loop closes: motion at frame 32 equals frame 0', seamless)
    check('comment block holds the script byte for byte', comment)
    check('--extract prints the script byte for byte', extract_cli)
    check('source from the GIF rebuilds the identical GIF', rebuild)
    good = sum(results)
    print('%d ok, %d FAIL' % (good, len(results) - good))
    print('PASS' if all(results) else 'FAIL')
    return 0 if all(results) else 1


if __name__ == '__main__':
    sys.exit(main())
