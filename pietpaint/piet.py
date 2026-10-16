#!/usr/bin/env python3
"""piet.py: a small Piet interpreter. Reads a P6 PPM, codel size 1.
usage: python3 piet.py [-c codel_size] [-n max_steps] image.ppm < input"""
import sys

HUES = [  # light, normal, dark for red yellow green cyan blue magenta
    [(0xFF, 0xC0, 0xC0), (0xFF, 0x00, 0x00), (0xC0, 0x00, 0x00)],
    [(0xFF, 0xFF, 0xC0), (0xFF, 0xFF, 0x00), (0xC0, 0xC0, 0x00)],
    [(0xC0, 0xFF, 0xC0), (0x00, 0xFF, 0x00), (0x00, 0xC0, 0x00)],
    [(0xC0, 0xFF, 0xFF), (0x00, 0xFF, 0xFF), (0x00, 0xC0, 0xC0)],
    [(0xC0, 0xC0, 0xFF), (0x00, 0x00, 0xFF), (0x00, 0x00, 0xC0)],
    [(0xFF, 0xC0, 0xFF), (0xFF, 0x00, 0xFF), (0xC0, 0x00, 0xC0)],
]
COLOR = {}
for h in range(6):
    for l in range(3):
        COLOR[HUES[h][l]] = (h, l)
WHITE, BLACK = (255, 255, 255), (0, 0, 0)
# (hue step, lightness step) -> command
OPS = [["nop", "push", "pop"], ["add", "sub", "mul"], ["div", "mod", "not"],
       ["greater", "pointer", "switch"], ["dup", "roll", "in_num"],
       ["in_char", "out_num", "out_char"]]
DX = [(1, 0), (0, 1), (-1, 0), (0, -1)]  # dp: right down left up


def read_ppm(path, codel=1):
    data = open(path, "rb").read()
    tok, i = [], 0
    while len(tok) < 4:
        while data[i:i+1].isspace():
            i += 1
        if data[i:i+1] == b"#":
            while data[i:i+1] != b"\n":
                i += 1
            continue
        j = i
        while not data[j:j+1].isspace():
            j += 1
        tok.append(data[i:j])
        i = j
    if tok[0] != b"P6" or tok[3] != b"255":
        raise SystemExit("piet: need a P6 PPM with maxval 255")
    w, h = int(tok[1]), int(tok[2])
    px = data[i+1:]
    if len(px) < w * h * 3:
        raise SystemExit("piet: truncated image")
    if w % codel or h % codel:
        raise SystemExit("piet: image size is not a multiple of the codel")
    # sample the top-left pixel of each codel
    grid = [[tuple(px[(y*w+x)*3:(y*w+x)*3+3]) for x in range(0, w, codel)]
            for y in range(0, h, codel)]
    w, h = w // codel, h // codel
    for row in grid:
        for c in row:
            if c not in COLOR and c not in (WHITE, BLACK):
                raise SystemExit("piet: colour %02x%02x%02x is not Piet" % c)
    return grid, w, h


class Piet:
    def __init__(self, grid, w, h, inp, out):
        self.g, self.w, self.h = grid, w, h
        self.inp, self.out = inp, out
        self.stack, self.dp, self.cc = [], 0, 0  # cc 0 left, 1 right
        self.x = self.y = 0
        self.cache = {}

    def colour(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.g[y][x]
        return BLACK

    def block(self, x, y):
        if (x, y) in self.cache:
            return self.cache[(x, y)]
        c, seen, todo = self.g[y][x], {(x, y)}, [(x, y)]
        while todo:
            a, b = todo.pop()
            for dx, dy in DX:
                n = (a + dx, b + dy)
                if n not in seen and self.colour(*n) == c:
                    seen.add(n)
                    todo.append(n)
        for p in seen:
            self.cache[p] = seen
        return seen

    def exit_codel(self, blk):
        dx, dy = DX[self.dp]
        far = max(p[0] * dx + p[1] * dy for p in blk)
        edge = [p for p in blk if p[0] * dx + p[1] * dy == far]
        # the codel chooser turns relative to dp: left is dp-1, right is dp+1
        cx, cy = DX[(self.dp + (1 if self.cc else -1)) % 4]
        return max(edge, key=lambda p: p[0] * cx + p[1] * cy)

    def slide(self, x, y):
        """walk through white in dp direction; None if trapped"""
        seen = set()
        while True:
            dx, dy = DX[self.dp]
            nx, ny = x + dx, y + dy
            c = self.colour(nx, ny)
            if c == WHITE:
                x, y = nx, ny
                continue
            if c != BLACK:
                return nx, ny
            if (x, y, self.dp, self.cc) in seen:
                return None
            seen.add((x, y, self.dp, self.cc))
            self.cc ^= 1
            self.dp = (self.dp + 1) % 4

    def step(self):
        """one transition; False when the program halts"""
        blk = self.block(self.x, self.y)
        for attempt in range(8):
            ex, ey = self.exit_codel(blk)
            dx, dy = DX[self.dp]
            nx, ny = ex + dx, ey + dy
            c = self.colour(nx, ny)
            if c == WHITE:
                r = self.slide(nx, ny)
                if r is None:
                    return False
                self.x, self.y = r
                return True
            if c != BLACK:
                old = self.g[self.y][self.x]
                self.x, self.y = nx, ny
                h0, l0 = COLOR[old]
                h1, l1 = COLOR[c]
                self.do(OPS[(h1 - h0) % 6][(l1 - l0) % 3], len(blk))
                return True
            if attempt % 2 == 0:
                self.cc ^= 1
            else:
                self.dp = (self.dp + 1) % 4
        return False

    def do(self, op, size):
        s = self.stack
        if op == "push":
            s.append(size)
        elif op == "nop":
            pass
        elif op == "pop":
            if s:
                s.pop()
        elif op in ("add", "sub", "mul", "div", "mod", "greater"):
            if len(s) < 2 or (op in ("div", "mod") and s[-1] == 0):
                return
            b, a = s.pop(), s.pop()
            s.append({"add": lambda: a + b, "sub": lambda: a - b,
                      "mul": lambda: a * b, "div": lambda: a // b,
                      "mod": lambda: a % b,
                      "greater": lambda: int(a > b)}[op]())
        elif op == "not":
            if s:
                s.append(int(s.pop() == 0))
        elif op == "pointer":
            if s:
                self.dp = (self.dp + s.pop()) % 4
        elif op == "switch":
            if s:
                self.cc = (self.cc + s.pop()) % 2
        elif op == "dup":
            if s:
                s.append(s[-1])
        elif op == "roll":
            if len(s) < 2:
                return
            n, d = s[-1], s[-2]
            if n < 0 or n > len(s) - 2:
                return
            s.pop(), s.pop()
            if n:
                d %= n
                top = s[len(s) - n:]
                del s[len(s) - n:]
                s.extend(top[-d:] + top[:-d] if d else top)
        elif op == "in_num":
            txt = ""
            while True:
                ch = self.inp.read(1)
                if not ch or not (ch.isdigit() or (ch == "-" and not txt)):
                    break
                txt += ch
            if txt and txt != "-":
                s.append(int(txt))
        elif op == "in_char":
            ch = self.inp.read(1)
            if ch:
                s.append(ord(ch))
        elif op == "out_num":
            if s:
                self.out.write(str(s.pop()))
        elif op == "out_char":
            if s:
                self.out.write(chr(s.pop() % 0x110000))


def main(argv):
    args, limit, codel = [], 1000000, 1
    i = 1
    while i < len(argv):
        if argv[i] == "-n":
            limit = int(argv[i + 1])
            i += 2
        elif argv[i] == "-c":
            codel = int(argv[i + 1])
            i += 2
        else:
            args.append(argv[i])
            i += 1
    if len(args) != 1:
        raise SystemExit(__doc__)
    grid, w, h = read_ppm(args[0], codel)
    if grid[0][0] in (WHITE, BLACK):
        raise SystemExit("piet: top-left codel must be a colour")
    m = Piet(grid, w, h, sys.stdin, sys.stdout)
    for _ in range(limit):
        if not m.step():
            break
    else:
        raise SystemExit("piet: step limit reached")
    sys.stdout.flush()


if __name__ == "__main__":
    main(sys.argv)
