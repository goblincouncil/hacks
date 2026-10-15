"""Reference torus in Python, used by check.sh to judge donut.awk.

usage: python3 ref.py N   prints N plain frames, each ended by a -- line
"""
import math
import sys

RAMP = ".,-~:;=!*#$@"


def frame(k):
    A, B = k * 0.04, k * 0.02
    e, g, m, n = math.sin(A), math.cos(A), math.cos(B), math.sin(B)
    zbuf = {}
    out = {}
    for jj in range(90):
        j = jj * 0.07
        d, f = math.cos(j), math.sin(j)
        h = d + 2
        for ii in range(314):
            i = ii * 0.02
            c, l = math.sin(i), math.cos(i)
            D = 1 / (c * h * e + f * g + 5)
            t = c * h * g - f * e
            x = int(40 + 30 * D * (l * h * m - t * n))
            y = int(12 + 15 * D * (l * h * n + t * m))
            o = x + 80 * y
            N = int(8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))
            if 0 < y < 22 and 0 < x < 80 and D > zbuf.get(o, 0):
                zbuf[o] = D
                out[o] = RAMP[max(N, 0)]
    rows = []
    for y in range(22):
        rows.append("".join(out.get(x + 80 * y, " ") for x in range(80)).rstrip(" "))
    return "\n".join(rows) + "\n--\n"


if __name__ == "__main__":
    sys.stdout.write("".join(frame(k) for k in range(int(sys.argv[1]))))
