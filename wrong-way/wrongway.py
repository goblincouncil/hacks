#!/usr/bin/env python3
"""wrong-way: walking directions that only land on places the map does not show.

The map lists intersections only. Every intersection is real, and every other
cell is a street that does not exist. The route never steps on a real
intersection until it reaches the goal.
"""
import sys
from collections import deque

SIZE = 21
START = (4, 4)
GOAL = (16, 16)
DIRS = [("north", 0, -1), ("east", 1, 0), ("south", 0, 1), ("west", -1, 0)]


def is_real(x, y):
    return x % 4 == 0 and y % 4 == 0


def route(start, goal):
    prev = {start: None}
    q = deque([start])
    while q:
        cur = q.popleft()
        if cur == goal:
            break
        for name, dx, dy in DIRS:
            nxt = (cur[0] + dx, cur[1] + dy)
            if not (0 <= nxt[0] < SIZE and 0 <= nxt[1] < SIZE):
                continue
            if nxt in prev:
                continue
            if nxt != goal and is_real(*nxt):
                continue
            prev[nxt] = (cur, name)
            q.append(nxt)
    if goal not in prev:
        return None
    steps = []
    cur = goal
    while prev[cur] is not None:
        cur, name = prev[cur]
        steps.append(name)
    steps.reverse()
    return steps


def runs(steps):
    out = []
    for s in steps:
        if out and out[-1][0] == s:
            out[-1][1] += 1
        else:
            out.append([s, 1])
    return out


def main(argv):
    start, goal = START, GOAL
    if len(argv) == 3:
        start = tuple(int(v) for v in argv[1].split(","))
        goal = tuple(int(v) for v in argv[2].split(","))
    steps = route(start, goal)
    if steps is None:
        print("no route. the map is too honest.")
        return 1
    print("From %d,%d to %d,%d:" % (start + goal))
    for i, (name, n) in enumerate(runs(steps), 1):
        print("%2d. walk %s %d block%s" % (i, name, n, "" if n == 1 else "s"))
    print("You have arrived. (You have not.)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
