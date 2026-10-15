import re
import sys

sys.path.insert(0, sys.argv[1])
import wrongway as w


def replay(text):
    m = re.search(r"From (\d+),(\d+) to (\d+),(\d+):", text)
    if not m:
        raise AssertionError("no header")
    x, y, gx, gy = map(int, m.groups())
    if (x, y) != w.START or (gx, gy) != w.GOAL:
        raise AssertionError("wrong start or goal")
    moves = re.findall(r"walk (north|east|south|west) (\d+) block", text)
    if not moves:
        raise AssertionError("no moves")
    void = 0
    for name, n in moves:
        dx, dy = [(a, b) for nm, a, b in w.DIRS if nm == name][0]
        for _ in range(int(n)):
            x += dx
            y += dy
            if not (0 <= x < w.SIZE and 0 <= y < w.SIZE):
                raise AssertionError("left the map")
            if (x, y) != (gx, gy):
                if w.is_real(x, y):
                    raise AssertionError("step %d,%d is a real intersection" % (x, y))
                void += 1
    if (x, y) != (gx, gy):
        raise AssertionError("did not land on goal")
    if "arrived" not in text:
        raise AssertionError("no arrival line")
    return void, len(moves)


text = open(sys.argv[2]).read()
void, turns = replay(text)
if void == 0:
    raise SystemExit("no off-map landings")

cheat = "From 4,4 to 4,8:\n 1. walk south 4 blocks\nYou have arrived. (You have not.)\n"
try:
    replay(cheat)
except AssertionError:
    pass
else:
    raise SystemExit("cheat accepted")

print("ok: %d off-map landings over %d turns; intersection cheat refused" % (void, turns))
