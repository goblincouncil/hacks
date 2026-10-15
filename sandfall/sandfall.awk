# sandfall.awk: a falling-sand pile in plain POSIX awk.
# Usage: awk -v W=12 -v H=8 -v N=30 -v SEED=3 -f sandfall.awk
# Drops up to N grains at random columns, one per frame, then keeps stepping
# until nothing moves. Prints the grid ('#' grain, '.' empty, row 0 on top),
# then a line "drops=A" where A is how many drops found an empty top cell.

BEGIN {
	if (W == "") W = 12
	if (H == "") H = 8
	if (N == "") N = 30
	if (SEED == "") SEED = 1
	srand(SEED)
	acc = 0
	for (f = 0; f < N; f++) {
		c = int(rand() * W)
		if (!g[0, c]) { g[0, c] = 1; acc++ }
		step()
	}
	while (step() > 0) { }
	for (y = 0; y < H; y++) {
		line = ""
		for (x = 0; x < W; x++) line = line (g[y, x] ? "#" : ".")
		print line
	}
	print "drops=" acc
}

# One step: bottom-up, so a grain never moves twice in the same frame.
# A grain falls straight down if it can, else slides diagonally, trying a
# random side first.
function step(   y, x, d, moved) {
	moved = 0
	for (y = H - 2; y >= 0; y--) {
		for (x = 0; x < W; x++) {
			if (!g[y, x]) continue
			if (!g[y + 1, x]) {
				g[y + 1, x] = 1; g[y, x] = 0; moved++
				continue
			}
			d = (rand() < 0.5) ? -1 : 1
			if (slide(y, x, d) || slide(y, x, -d)) moved++
		}
	}
	return moved
}

function slide(y, x, d,   nx) {
	nx = x + d
	if (nx < 0 || nx >= W) return 0
	if (g[y + 1, nx]) return 0
	g[y + 1, nx] = 1; g[y, x] = 0
	return 1
}
