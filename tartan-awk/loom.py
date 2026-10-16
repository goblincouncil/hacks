# loom.py - independent reference loom for check.sh.
# Written differently from tartan.awk on purpose: stripes become a list,
# the mirror is a list slice, and the weave is a 4x4 lift plan table.
# usage: python3 loom.py 'K4 R24 K24 Y4' size  -> prints P3 to stdout
import sys

PALETTE = {
    'K': (16, 16, 16), 'W': (240, 240, 232), 'R': (190, 20, 30),
    'G': (20, 100, 40), 'B': (20, 40, 140), 'Y': (230, 190, 20),
    'N': (20, 25, 60), 'P': (110, 40, 120), 'O': (220, 110, 20),
    'A': (140, 140, 150),
}
# 2/2 twill lift plan: row = weft pick mod 4, column = warp end mod 4,
# 1 means the warp end is lifted, so the warp colour shows.
LIFT = [[1, 1, 0, 0],
        [1, 0, 0, 1],
        [0, 0, 1, 1],
        [0, 1, 1, 0]]

def threads(sett):
    stripes = [(s[0], int(s[1:])) for s in sett.split()]
    seq = stripes + stripes[-2:0:-1]   # mirror, pivots once
    out = []
    for c, w in seq:
        out.extend([c] * w)
    return out

def weave(sett, size):
    th = threads(sett)
    rows = []
    for y in range(size):
        row = []
        for x in range(size):
            warp_up = LIFT[y % 4][x % 4]
            row.append(PALETTE[th[x % len(th)] if warp_up else th[y % len(th)]])
        rows.append(row)
    return rows

if __name__ == '__main__':
    sett, size = sys.argv[1], int(sys.argv[2])
    print('P3'); print(size, size); print(255)
    for row in weave(sett, size):
        print(' '.join('%d %d %d' % p for p in row))
