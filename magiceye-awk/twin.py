#!/usr/bin/env python3
"""Independent Python twin of magiceye.awk, written from the spec, not the awk.

usage: python3 twin.py MAP [P] [SEED]   (prints the stereogram, exit 1 on bad input)
"""
import string
import sys

ALPHABET = string.ascii_uppercase + string.ascii_lowercase


def park_miller(seed):
    while True:
        seed = seed * 16807 % 2147483647
        yield seed


def stereogram(rows, period, seed):
    width = max((len(r) for r in rows), default=0)
    rng = park_miller(seed)
    out = []
    for r in rows:
        depth = [int(ch) if ch.isdigit() else 0 for ch in r.ljust(width, "0")]
        line = [ALPHABET[next(rng) % 52] for _ in range(period)]
        for d in depth:
            line.append(line[len(line) - (period - d)])
        out.append("".join(line))
    return out


def main():
    path = sys.argv[1]
    period = int(sys.argv[2]) if len(sys.argv) > 2 else 16
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    with open(path) as f:
        rows = [ln.rstrip("\n").rstrip("\r") for ln in f]
    if not rows or any(set(r) - set("0123456789. ") for r in rows) or not 10 <= period <= 99:
        sys.exit(1)
    print("\n".join(stereogram(rows, period, seed)))


if __name__ == "__main__":
    main()
