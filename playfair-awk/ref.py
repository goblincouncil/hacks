import sys
key, mode = sys.argv[1], sys.argv[2]
sq = []
for c in (key.upper() + "ABCDEFGHIKLMNOPQRSTUVWXYZ").replace("J", "I"):
    if c.isalpha() and c not in sq: sq.append(c)
d = 1 if mode == "e" else -1
for line in sys.stdin:
    t = [c for c in line.upper().replace("J", "I") if "A" <= c <= "Z"]
    o = []; i = 0
    while i < len(t):
        a = t[i]; b = t[i+1] if i+1 < len(t) else "X"
        if mode == "e" and a == b: b = "X"; i += 1
        else: i += 2
        ra, ca = divmod(sq.index(a), 5); rb, cb = divmod(sq.index(b), 5)
        if ra == rb: ca, cb = (ca+d) % 5, (cb+d) % 5
        elif ca == cb: ra, rb = (ra+d) % 5, (rb+d) % 5
        else: ca, cb = cb, ca
        o.append(sq[ra*5+ca] + sq[rb*5+cb])
    print("".join(o))
