# sandfall

A falling-sand pile in POSIX awk. Grains drop one per frame into random columns of a small grid. A grain falls straight down when it can, and slides diagonally when it can't. After the last drop the program keeps stepping until nothing moves, then prints the pile.

## Run it

    awk -v W=12 -v H=8 -v N=30 -v SEED=3 -f sandfall.awk

W and H set the grid size (default 12 by 8). N is the number of drops (default 30). SEED seeds awk's random number generator (default 1). Row 0 is the top.

The last line is `drops=A`, where A is the number of grains that actually entered the grid. A drop is skipped when the top cell of its column is already full.

## Test it

    sh check.sh

The check does not compare against a reference model. It checks invariants: the grid has the right shape, the grain count equals the drops count (no grain vanishes or appears), the pile is settled (no grain could still fall or slide), the same seed gives the same output, different seeds give different piles, and a copy with one line sabotaged (falling grains disappear) is caught.

## How it works

The grid is a flat awk array `g[y, x]`. Each step scans rows bottom-up, so a grain moves at most once per step: a grain that moves down lands in a row that has already been scanned. A grain that can fall moves down. Otherwise it tries one diagonal, chosen at random first, then the other. The step repeats until a step moves nothing.

No dependencies beyond awk.

## Limits

Small grid, plain text, no animation. The only physics is the fall and slide rule.

MIT license.