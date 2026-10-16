"""ref.py: an independent Langton's ant plus a sixel decoder, used by check.sh.

usage:
  python3 ref.py check STEPS SCALE FILE.six   decode FILE.six, compare to the ant
  python3 ref.py ppm   STEPS SCALE FILE.ppm   compare an ImageMagick PPM to the ant
  python3 ref.py cells STEPS                  print the number of black cells
"""
import sys

PALETTE = [(95, 90, 75), (15, 10, 25), (90, 15, 10)]  # percent RGB: paper, ink, ant


def ant(steps):
    """Positions as complex numbers, y grows downward, heading starts up."""
    pos, head, black = 0j, -1j, set()
    for _ in range(steps):
        if pos in black:
            black.discard(pos)
            head *= -1j  # left turn (y down)
        else:
            black.add(pos)
            head *= 1j  # right turn (y down)
        pos += head
    return pos, black


def expected(steps, scale):
    pos, black = ant(steps)
    pts = list(black) + [pos, 0j]
    xs = [int(p.real) for p in pts]
    ys = [int(p.imag) for p in pts]
    # the awk script tracks every square the ant stood on; those cover
    # all black cells, the start and the final square
    x0, x1, y0, y1 = min(xs) - 1, max(xs) + 1, min(ys) - 1, max(ys) + 1
    w, h = (x1 - x0 + 1) * scale, (y1 - y0 + 1) * scale
    grid = []
    for py in range(h):
        row = []
        for px in range(w):
            c = complex(x0 + px // scale, y0 + py // scale)
            row.append(2 if c == pos else 1 if c in black else 0)
        grid.append(row)
    return w, h, grid


def decode_sixel(data):
    """Minimal sixel decoder: DCS intro, raster attributes, colour
    definitions, #select, !repeat, $ carriage return, - next band."""
    if not data.startswith("\033P") or not data.rstrip("\n").endswith("\033\\"):
        raise ValueError("bad DCS framing")
    q = data.index("q")
    body = data[q + 1:data.rstrip("\n").rindex("\033\\")]
    i, n = 0, len(body)

    def num():
        nonlocal i
        j = i
        while i < n and body[i].isdigit():
            i += 1
        return int(body[j:i]) if i > j else 0

    w = h = None
    pix, colors = {}, {}
    x = band = cur = 0
    while i < n:
        ch = body[i]
        if ch == '"':
            i += 1
            args = [num()]
            while i < n and body[i] == ";":
                i += 1
                args.append(num())
            _, _, w, h = args
        elif ch == "#":
            i += 1
            args = [num()]
            while i < n and body[i] == ";":
                i += 1
                args.append(num())
            if len(args) == 5:
                if args[1] != 2:
                    raise ValueError("only RGB colours expected")
                colors[args[0]] = tuple(args[2:])
            cur = args[0]
        elif ch == "!":
            i += 1
            count = num()
            s = body[i]
            i += 1
            for _ in range(count):
                put(pix, x, band, s, cur)
                x += 1
        elif ch == "$":
            x = 0
            i += 1
        elif ch == "-":
            x = 0
            band += 1
            i += 1
        elif "?" <= ch <= "~":
            put(pix, x, band, ch, cur)
            x += 1
            i += 1
        else:
            raise ValueError("unexpected byte %r at %d" % (ch, i))
    return w, h, pix, colors


def put(pix, x, band, ch, c):
    bits = ord(ch) - 63
    for r in range(6):
        if bits >> r & 1:
            pix[(x, band * 6 + r)] = c


def cmd_check(steps, scale, path):
    w, h, grid = expected(steps, scale)
    gw, gh, pix, colors = decode_sixel(open(path, encoding="latin-1").read())
    if (gw, gh) != (w, h):
        return "size %sx%s, expected %dx%d" % (gw, gh, w, h)
    if colors != dict(enumerate(PALETTE)):
        return "palette %r" % colors
    if any(not (0 <= px < w and 0 <= py < h) for px, py in pix):
        return "pixels drawn outside the raster"
    bad = sum(pix.get((px, py)) != grid[py][px] for py in range(h) for px in range(w))
    if bad:
        return "%d of %d pixels differ" % (bad, w * h)
    return None


def cmd_ppm(steps, scale, path):
    w, h, grid = expected(steps, scale)
    raw = open(path, "rb").read()
    parts, i = [], 0
    while len(parts) < 4:  # P6 w h maxval, whitespace separated
        while raw[i:i + 1].isspace():
            i += 1
        j = i
        while not raw[j:j + 1].isspace():
            j += 1
        parts.append(raw[i:j])
        i = j
    i += 1
    if parts[0] != b"P6" or int(parts[3]) != 255:
        return "not an 8-bit P6 ppm"
    if (int(parts[1]), int(parts[2])) != (w, h):
        return "size %sx%s, expected %dx%d" % (int(parts[1]), int(parts[2]), w, h)
    rgb = [tuple(round(p * 255 / 100) for p in c) for c in PALETTE]
    bad = 0
    for py in range(h):
        for px in range(w):
            k = i + 3 * (py * w + px)
            got = raw[k:k + 3]
            want = rgb[grid[py][px]]
            if len(got) != 3 or max(abs(a - b) for a, b in zip(got, want)) > 3:
                bad += 1
    if bad:
        return "%d of %d pixels differ" % (bad, w * h)
    return None


def main(argv):
    if argv[1] == "cells":
        print(len(ant(int(argv[2]))[1]))
        return 0
    fn = {"check": cmd_check, "ppm": cmd_ppm}[argv[1]]
    err = fn(int(argv[2]), int(argv[3]), argv[4])
    if err:
        print("FAIL: " + err)
        return 1
    w, h, _ = expected(int(argv[2]), int(argv[3]))
    print("match %dx%d" % (w, h))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
