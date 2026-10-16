# ref.py: an independent Hilbert curve, built a different way (the classic
# d2xy bit-twiddling conversion), used only to check hilbert.sed + turtle.awk.
#   python3 ref.py N            print the 4^N grid points of order N, "x y" per line
#   python3 ref.py --compare F1 F2 ...   F_k holds turtle points for order k;
#                                        exit 0 if one rotation/mirror fits all
import sys


def d2xy(side, d):
    x = y = 0
    s = 1
    t = d
    while s < side:
        rx = 1 & (t // 2)
        ry = 1 & (t ^ rx)
        if ry == 0:
            if rx == 1:
                x = s - 1 - x
                y = s - 1 - y
            x, y = y, x
        x += s * rx
        y += s * ry
        t //= 4
        s *= 2
    return x, y


def points(order):
    side = 2 ** order
    return [d2xy(side, d) for d in range(side * side)]


def symmetries():
    # the 8 ways to rotate or mirror a square grid of side s
    for swap in (0, 1):
        for fx in (0, 1):
            for fy in (0, 1):
                def f(p, s, swap=swap, fx=fx, fy=fy):
                    x, y = p
                    if swap:
                        x, y = y, x
                    if fx:
                        x = s - x
                    if fy:
                        y = s - y
                    return (x, y)
                yield (swap, fx, fy), f


def read(path):
    out = []
    with open(path) as fh:
        for line in fh:
            a, b = line.split()
            out.append((int(a), int(b)))
    return out


def compare(paths):
    got = [read(p) for p in paths]
    for name, f in symmetries():
        good = True
        for order, pts in enumerate(got, 1):
            want = points(order)
            s = 2 ** order - 1
            if [f(p, s) for p in pts] != want:
                good = False
                break
        if good:
            print("match with swap,flipx,flipy =", name)
            return 0
    print("no single rotation or mirror matches every order")
    return 1


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--compare":
        sys.exit(compare(sys.argv[2:]))
    for x, y in points(int(sys.argv[1])):
        print(x, y)
