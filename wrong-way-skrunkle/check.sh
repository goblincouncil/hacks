#!/bin/sh
# Exits 0 only if wrong-way.py gives valid directions over a real street grid
# and the checker itself catches a sabotaged direction.
set -e
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")"

python3 -I - <<'EOF'
import importlib.util, re, subprocess, sys

spec = importlib.util.spec_from_file_location("ww", "wrong-way.py")
ww = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ww)

LEG = re.compile(r"^Head (North|South|East|West) for (\d+) blocks? to (.+)\.$")
DELTA = {v: k for k, v in ww.STEP.items()}


def verify(text, m):
    """Walk the directions on the street grid. Return an error string or None."""
    w, h, names = m["w"], m["h"], m["names"]
    lines = text.splitlines()
    if lines[0] != "Start at %s." % names[(0, 0)]:
        return "bad start line"
    pos = (0, 0)
    prev_dir = None
    for line in lines[1:-1]:
        mo = LEG.match(line)
        if not mo:
            return "unparsed leg: %r" % line
        d, n, dest = mo.group(1), int(mo.group(2)), mo.group(3)
        if d == prev_dir:
            return "two legs in the same direction were not merged"
        prev_dir = d
        dx, dy = DELTA[d]
        for _ in range(n):
            nxt = (pos[0] + dx, pos[1] + dy)
            if nxt not in names:
                return "walked off the grid at %r" % (nxt,)
            if frozenset((pos, nxt)) not in m["open"]:
                return "walked through a closed street at %r" % (nxt,)
            pos = nxt
        if names[pos] != dest:
            return "leg ends at %s, text says %s" % (names[pos], dest)
    if pos != (w - 1, h - 1):
        return "walk ends off target"
    if lines[-1] != "You have arrived at %s." % names[pos]:
        return "bad arrival line"
    return None


count = 0
seen = set()
for seed in range(1, 40):
    for w, h in [(2, 2), (5, 4), (8, 6)]:
        m = ww.make_map(seed, w, h)
        names = m["names"]
        assert len(names) == w * h, "cell count"
        assert len(set(names.values())) == w * h, "names not unique"
        # every street joins two neighbouring cells on the grid
        for e in m["open"]:
            a, b = tuple(e)
            assert abs(a[0] - b[0]) + abs(a[1] - b[1]) == 1, "bad street"
        # every place can be reached from the start
        reach, todo = {(0, 0)}, [(0, 0)]
        while todo:
            c = todo.pop()
            for dx, dy in ww.STEP:
                n = (c[0] + dx, c[1] + dy)
                if n in names and n not in reach and frozenset((c, n)) in m["open"]:
                    reach.add(n)
                    todo.append(n)
        assert len(reach) == w * h, "grid not connected"
        text = ww.render(m, (0, 0), (w - 1, h - 1))
        assert text == ww.render(m, (0, 0), (w - 1, h - 1)), "not deterministic"
        err = verify(text, m)
        assert err is None, "seed %d %dx%d: %s" % (seed, w, h, err)
        seen.add(text)
        count += 1

assert len(seen) > 100, "maps too alike"

# the checker must catch a wrong direction
m = ww.make_map(1, 5, 4)
text = ww.render(m, (0, 0), (4, 3))
bad = text.replace("Head East", "Head West", 1)
assert bad != text
assert verify(bad, m) is not None, "sabotaged walk was not caught"

# the command line output matches the library
out = subprocess.run([sys.executable, "-I", "wrong-way.py", "1", "5", "4"],
                     capture_output=True, text=True, check=True).stdout
assert out == ww.render(m, (0, 0), (4, 3)), "cli output differs"

print("checked %d maps, %d distinct outputs" % (count, len(seen)))
print("sabotage caught")
EOF

echo PASS
