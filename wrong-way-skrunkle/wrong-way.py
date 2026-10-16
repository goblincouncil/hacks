#!/usr/bin/env python3
"""wrong-way: seeded driving directions between places that are not there.

A grid of intersections, each with an invented name. Streets join them as a
random spanning tree plus some extra streets, so every place can be reached.
The directions are real turn-by-turn text for that grid. The places are not.

Usage: wrong-way.py [seed] [width] [height]
"""
import random
import sys
from collections import deque

FIRST = ["vel", "dor", "mun", "ka", "tess", "ob", "ri", "lan", "quo", "fen",
         "sil", "ar", "mop", "zen", "ul", "bre", "ta", "nod", "ill", "pex"]
SECOND = ["fen", "ton", "mer", "holt", "wick", "vale", "dun", "sar", "pell",
          "gorn", "lock", "mire", "stow", "crane"]
KIND = ["Ford", "Gate", "Wick", "Holm", "Mere", "Stead", "Moor", "Cross"]

STEP = {(0, -1): "North", (0, 1): "South", (1, 0): "East", (-1, 0): "West"}


def make_map(seed, w, h, extra=0.25):
    rng = random.Random(seed)
    names = {}
    used = set()
    for y in range(h):
        for x in range(w):
            name = None
            while name is None or name in used:
                name = "%s%s %s" % (rng.choice(FIRST).capitalize(),
                                    rng.choice(SECOND), rng.choice(KIND))
            used.add(name)
            names[(x, y)] = name

    cells = [(x, y) for y in range(h) for x in range(w)]
    edges = []
    for (x, y) in cells:
        if x + 1 < w:
            edges.append(((x, y), (x + 1, y)))
        if y + 1 < h:
            edges.append(((x, y), (x, y + 1)))
    rng.shuffle(edges)

    parent = {c: c for c in cells}

    def find(c):
        while parent[c] != c:
            parent[c] = parent[parent[c]]
            c = parent[c]
        return c

    open_streets = set()
    spare = []
    for a, b in edges:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb
            open_streets.add(frozenset((a, b)))
        else:
            spare.append((a, b))
    for a, b in spare:
        if rng.random() < extra:
            open_streets.add(frozenset((a, b)))
    return {"w": w, "h": h, "names": names, "open": open_streets}


def route(m, start, goal):
    prev = {start: None}
    queue = deque([start])
    while queue:
        c = queue.popleft()
        if c == goal:
            break
        for dx, dy in STEP:
            n = (c[0] + dx, c[1] + dy)
            if n in m["names"] and n not in prev and frozenset((c, n)) in m["open"]:
                prev[n] = c
                queue.append(n)
    path = []
    c = goal
    while c is not None:
        path.append(c)
        c = prev[c]
    return path[::-1]


def directions(m, path):
    legs = []
    i = 1
    while i < len(path):
        dx = path[i][0] - path[i - 1][0]
        dy = path[i][1] - path[i - 1][1]
        j = i
        while j < len(path) and (path[j][0] - path[j - 1][0],
                                 path[j][1] - path[j - 1][1]) == (dx, dy):
            j += 1
        n = j - i
        legs.append("Head %s for %d block%s to %s."
                    % (STEP[(dx, dy)], n, "" if n == 1 else "s",
                       m["names"][path[j - 1]]))
        i = j
    return legs


def render(m, start, goal):
    lines = ["Start at %s." % m["names"][start]]
    lines += directions(m, route(m, start, goal))
    lines.append("You have arrived at %s." % m["names"][goal])
    return "\n".join(lines) + "\n"


def main(argv):
    seed = int(argv[1]) if len(argv) > 1 else 1
    w = int(argv[2]) if len(argv) > 2 else 5
    h = int(argv[3]) if len(argv) > 3 else 4
    m = make_map(seed, w, h)
    sys.stdout.write(render(m, (0, 0), (w - 1, h - 1)))


if __name__ == "__main__":
    main(sys.argv)
