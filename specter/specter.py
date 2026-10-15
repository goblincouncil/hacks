#!/usr/bin/env python3
"""specter: paint a picture into the spectrogram of a WAV, and read it back.

usage:
  specter.py paint OUT.wav        write the sound
  specter.py read IN.wav [OUT.pgm]  print the picture heard in a WAV, optionally save it
  specter.py picture              print the picture as painted, no sound involved
"""
import math
import struct
import sys
import wave

RATE = 8000          # samples per second
COL = 400            # samples per column: 50 ms
ROWS, COLS = 32, 96
BASE, STEP = 500, 100  # Hz. RATE/COL = 20 Hz, and every tone is a multiple of it
PEAK = 32000         # int16 level of a full column of full-bright pixels
RAMP = " .:-=+*#%@"

FONT = {
    "S": ["111", "100", "111", "001", "111"],
    "P": ["111", "101", "111", "100", "100"],
    "E": ["111", "100", "110", "100", "111"],
    "C": ["111", "100", "100", "100", "111"],
    "T": ["111", "010", "010", "010", "010"],
    "R": ["110", "101", "110", "101", "101"],
}
TITLE = "SPECTER"


def freq(row):
    """Row 0 is the top of the picture, so it gets the highest pitch."""
    return BASE + STEP * (ROWS - 1 - row)


def ball(x, y):
    """Sphere-trace one orthographic ray at (x, y). Returns brightness 0..1."""
    cx, cy, cz, r = 0.0, 0.0, 0.0, 0.92
    z = -3.0
    for _ in range(64):
        d = math.sqrt((x - cx) ** 2 + (y - cy) ** 2 + (z - cz) ** 2) - r
        if d < 1e-4:
            break
        z += d
        if z > 3.0:
            return 0.0
    else:
        return 0.0
    nx, ny, nz = (x - cx) / r, (y - cy) / r, (z - cz) / r
    lx, ly, lz = -0.55, 0.6, -0.58          # light from upper left, in front
    ll = math.sqrt(lx * lx + ly * ly + lz * lz)
    diff = max(0.0, (nx * lx + ny * ly + nz * lz) / ll)
    # Blinn-ish highlight: half vector between light and the viewer (0,0,-1)
    hx, hy, hz = lx / ll, ly / ll, lz / ll - 1.0
    hl = math.sqrt(hx * hx + hy * hy + hz * hz)
    spec = max(0.0, (nx * hx + ny * hy + nz * hz) / hl) ** 24
    return min(1.0, 0.12 + 0.7 * diff + 0.5 * spec)


def picture():
    """The image, ROWS lists of COLS floats in 0..1."""
    img = [[0.0] * COLS for _ in range(ROWS)]
    for r in range(ROWS):
        for c in range(36):
            x = (c - 17.5) / 16.0
            y = (15.5 - r) / 16.0
            img[r][c] = round(ball(x, y), 3)
    for i, ch in enumerate(TITLE):
        x0 = 38 + i * 8
        for fr, line in enumerate(FONT[ch]):
            for fc, bit in enumerate(line):
                if bit == "1":
                    for dr in range(4):
                        for dc in range(2):
                            img[6 + fr * 4 + dr][x0 + fc * 2 + dc] = 1.0
    return img


def paint(img):
    """Image to int16 samples. Each lit pixel is one tone for one column."""
    out = []
    for c in range(COLS):
        lit = [(r, img[r][c]) for r in range(ROWS) if img[r][c] > 0]
        for k in range(COL):
            n = c * COL + k                # global index keeps phase continuous
            s = 0.0
            for r, v in lit:
                phase = (r * r * 0.7) % (2 * math.pi)  # spread phases, tame peaks
                s += v * math.sin(2 * math.pi * freq(r) * n / RATE + phase)
            out.append(int(round(s * PEAK / ROWS)))
    return out


def write_wav(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(struct.pack("<%dh" % len(samples), *samples))


def read_wav(path):
    with wave.open(path, "rb") as w:
        if (w.getnchannels(), w.getsampwidth(), w.getframerate()) != (1, 2, RATE):
            raise SystemExit("specter: want mono 16-bit %d Hz" % RATE)
        data = w.readframes(w.getnframes())
    return list(struct.unpack("<%dh" % (len(data) // 2), data))


def goertzel(block, k):
    """Magnitude of DFT bin k of block, one tone at a time."""
    coeff = 2 * math.cos(2 * math.pi * k / len(block))
    s1 = s2 = 0.0
    for x in block:
        s1, s2 = x + coeff * s1 - s2, s1
    return math.sqrt(max(0.0, s1 * s1 + s2 * s2 - coeff * s1 * s2))


def listen(samples):
    """Samples back to the image, using one Goertzel filter per pixel."""
    cols = len(samples) // COL
    img = [[0.0] * cols for _ in range(ROWS)]
    for c in range(cols):
        block = samples[c * COL:(c + 1) * COL]
        for r in range(ROWS):
            k = freq(r) * COL // RATE
            amp = 2 * goertzel(block, k) / COL
            img[r][c] = amp * ROWS / PEAK
    return img


def ascii_art(img):
    rows = []
    for line in img:
        rows.append("".join(RAMP[min(len(RAMP) - 1, max(0, int(v * (len(RAMP) - 1) + 0.5)))]
                            for v in line).rstrip())
    return "\n".join(rows) + "\n"


def write_pgm(path, img, scale=6):
    h, w = len(img) * scale, len(img[0]) * scale
    px = bytearray()
    for line in img:
        row = bytearray()
        for v in line:
            row += bytes([min(255, max(0, int(v * 255 + 0.5)))]) * scale
        px += bytes(row) * scale
    with open(path, "wb") as f:
        f.write(b"P5\n%d %d\n255\n" % (w, h) + bytes(px))


def main(argv):
    if len(argv) >= 2 and argv[0] == "paint":
        write_wav(argv[1], paint(picture()))
    elif len(argv) >= 2 and argv[0] == "read":
        img = listen(read_wav(argv[1]))
        sys.stdout.write(ascii_art(img))
        if len(argv) >= 3:
            write_pgm(argv[2], img)
    elif argv[:1] == ["picture"]:
        sys.stdout.write(ascii_art(picture()))
    else:
        sys.stderr.write(__doc__)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
