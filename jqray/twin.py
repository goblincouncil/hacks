# twin.py: an independent Python version of jqray.jq, written to match it
# operation for operation so the two images agree byte for byte.
# usage: python3 twin.py [W H] > out.ppm
import math
import sys

W = int(sys.argv[1]) if len(sys.argv) > 1 else 160
H = int(sys.argv[2]) if len(sys.argv) > 2 else 120


def add(a, b): return [a[0] + b[0], a[1] + b[1], a[2] + b[2]]
def sub(a, b): return [a[0] - b[0], a[1] - b[1], a[2] - b[2]]
def mul(a, s): return [a[0] * s, a[1] * s, a[2] * s]
def dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
def norm(a): return mul(a, 1 / math.sqrt(dot(a, a)))


C = [0, 1, 3]
L = norm([-1, 2, -1.5])
HORIZON = [0.9, 0.95, 1]


def sphere(o, d):
    oc = sub(o, C)
    b = dot(oc, d)
    c = dot(oc, oc) - 1
    disc = b * b - c
    if disc > 0:
        t = 0 - b - math.sqrt(disc)
        return t if t > 0.001 else None
    return None


def floorhit(o, d):
    if d[1] < -0.001:
        t = (0 - o[1]) / d[1]
        return t if t > 0.001 else None
    return None


def sky(d):
    k = d[1] if d[1] > 0 else 0
    return [0.9 - 0.5 * k, 0.95 - 0.35 * k, 1]


def fog(c, t):
    f = t / (t + 25)
    return add(mul(c, 1 - f), mul(HORIZON, f))


def trace(o, d, depth):
    ts = sphere(o, d)
    tf = floorhit(o, d)
    if ts is not None and (tf is None or ts < tf):
        p = add(o, mul(d, ts))
        n = sub(p, C)
        r = sub(d, mul(n, 2 * dot(d, n)))
        diff = max(dot(n, L), 0)
        s = max(dot(r, L), 0) ** 32
        col = add(mul([0.05, 0.55, 0.1], 0.15 + 0.85 * diff), [s, s, s])
        if depth > 0:
            col = add(mul(col, 0.75), mul(trace(p, r, depth - 1), 0.25))
        return fog(col, ts)
    if tf is not None:
        p = add(o, mul(d, tf))
        odd = (math.floor(p[0]) + math.floor(p[2])) % 2
        base = [0.85, 0.2, 0.15] if odd == 1 else [0.9, 0.9, 0.85]
        shade = 0.35 if sphere(p, L) is not None else 1
        col = mul(base, (0.25 + 0.75 * L[1]) * shade)
        if depth > 0:
            col = add(mul(col, 0.8), mul(trace(p, [d[0], 0 - d[1], d[2]], depth - 1), 0.2))
        return fog(col, tf)
    return sky(d)


def pixel(x, y):
    u = (2 * (x + 0.5) / W - 1) * W / H
    v = 1 - 2 * (y + 0.5) / H
    c = trace([0, 1.2, -1.5], norm([u, v - 0.1, 1.6]), 2)
    return [math.floor(math.sqrt(min(max(ch, 0), 1)) * 255 + 0.5) for ch in c]


out = ["P3", "%d %d" % (W, H), "255"]
for y in range(H):
    out.append(" ".join(str(ch) for x in range(W) for ch in pixel(x, y)))
sys.stdout.write("\n".join(out) + "\n")
