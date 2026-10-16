#!/usr/bin/env python3
"""Read a Code 128 B barcode back out of a plain PBM (P1), no libraries.

It takes the middle pixel row, measures the bar and space runs, works out
the module width from the narrowest run, and matches each group of six
runs against the table in ref.py (kept there as bit strings, a different
form from the width codes in barcode.awk). Start, checksum and stop are
all verified. Prints the text, or exits 1 with a reason.
usage: python3 decode.py FILE.pbm
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ref import BITS  # noqa: E402


def runs(bits):
    return [len(m.group()) for m in re.finditer(r"1+|0+", bits)]


WIDTHS = {"".join(map(str, runs(b))): v for v, b in enumerate(BITS)}


def read_pbm(path):
    with open(path) as f:
        toks = []
        for line in f:
            line = line.split("#", 1)[0]
            toks.append(line.strip())
    data = " ".join(toks).split(None, 3)
    if len(data) < 4 or data[0] != "P1":
        raise ValueError("not a plain PBM")
    w, h = int(data[1]), int(data[2])
    px = re.sub(r"\s", "", data[3])
    if len(px) != w * h or set(px) - set("01"):
        raise ValueError("bad pixel data")
    return w, h, px


def decode(path):
    w, h, px = read_pbm(path)
    y = h // 2
    row = px[y * w:(y + 1) * w]
    first, last = row.find("1"), row.rfind("1")
    if first < 0:
        raise ValueError("no bars")
    if first < 10 or w - 1 - last < 10:
        raise ValueError("no quiet zone")
    r = runs(row[first:last + 1])
    mod = min(r)
    if any(x % mod for x in r):
        raise ValueError("runs are not whole modules")
    if first < 10 * mod or w - 1 - last < 10 * mod:
        raise ValueError("quiet zone under 10 modules")
    m = "".join(str(x // mod) for x in r)
    if len(m) < 6 + 7 or (len(m) - 7) % 6:
        raise ValueError("wrong number of bars")
    vals = []
    for i in range(0, len(m) - 7, 6):
        code = m[i:i + 6]
        if code not in WIDTHS:
            raise ValueError("unknown symbol " + code)
        vals.append(WIDTHS[code])
    if WIDTHS.get(m[-7:]) != 106:
        raise ValueError("no stop")
    if not vals or vals[0] != 104:
        raise ValueError("not start B")
    data, check = vals[1:-1], vals[-1]
    if not data:
        raise ValueError("no data")
    if (104 + sum(v * (i + 1) for i, v in enumerate(data))) % 103 != check:
        raise ValueError("bad checksum")
    if any(v > 94 for v in data):
        raise ValueError("control symbol in data")
    return "".join(chr(v + 32) for v in data)


if __name__ == "__main__":
    try:
        print(decode(sys.argv[1]))
    except (ValueError, OSError) as e:
        print("decode.py: " + str(e), file=sys.stderr)
        sys.exit(1)
