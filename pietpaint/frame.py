#!/usr/bin/env python3
"""frame.py: turn a P6 PPM into a picture you can look at.
usage: python3 frame.py in.ppm scale > out.ppm   (blow each codel up)
       python3 frame.py in.ppm                   (ANSI preview in a terminal)
"""
import sys
from piet import read_ppm


def main():
    grid, w, h = read_ppm(sys.argv[1])
    if len(sys.argv) > 2:
        s = int(sys.argv[2])
        rows = []
        for row in grid:
            line = b"".join(bytes(px) * s for px in row)
            rows += [line] * s
        sys.stdout.buffer.write(b"P6\n%d %d\n255\n" % (w * s, h * s) +
                                b"".join(rows))
        return
    for row in grid:
        sys.stdout.write("".join("\x1b[48;2;%d;%d;%dm  " % px for px in row))
        sys.stdout.write("\x1b[0m\n")


if __name__ == "__main__":
    main()
