# sandpile.awk: drop N grains on one cell of an Abelian sandpile, topple
# until every cell holds fewer than 4, and paint the result as a PPM.
# usage: awk -v N=10000 -v S=2 -f sandpile.awk > pile.ppm
BEGIN {
    if (N == "") N = 10000
    if (S == "") S = 1
    if (N !~ /^[0-9]+$/ || S !~ /^[1-9][0-9]*$/ || S + 0 > 64) {
        print "sandpile: N must be a whole number >= 0, S a whole number 1..64" > "/dev/stderr"
        exit 1
    }
    N += 0; S += 0
    # the four colours, one per height 0..3
    pal[0] = "16 12 32"; pal[1] = "40 120 200"
    pal[2] = "240 200 60"; pal[3] = "200 40 60"
    h[0, 0] = N; R = 0; busy = (N >= 4)
    # Abelian: order does not matter, so topple whole stacks at once.
    # A cell with h grains sends int(h/4) to each neighbour and keeps h%4.
    while (busy) {
        busy = 0; grow = 0
        for (y = -R; y <= R; y++) for (x = -R; x <= R; x++) {
            if (!((x, y) in h) || h[x, y] < 4) continue
            q = int(h[x, y] / 4); h[x, y] -= 4 * q
            h[x+1, y] += q; h[x-1, y] += q; h[x, y+1] += q; h[x, y-1] += q
            if (x == R || x == -R || y == R || y == -R) grow = 1
            busy = 1
        }
        if (grow) R++
    }
    # smallest square around the origin holding every grain
    E = 0
    for (k in h) if (h[k] > 0) {
        split(k, c, SUBSEP)
        a = c[1] < 0 ? -c[1] : c[1]; b = c[2] < 0 ? -c[2] : c[2]
        if (a > E) E = a
        if (b > E) E = b
    }
    W = (2 * E + 1) * S
    print "P3"; print W, W; print 255
    for (y = -E; y <= E; y++) {
        line = ""
        for (x = -E; x <= E; x++) {
            v = ((x, y) in h) ? h[x, y] : 0
            for (i = 0; i < S; i++) line = line (line == "" ? "" : " ") pal[v]
        }
        for (j = 0; j < S; j++) print line
    }
}
