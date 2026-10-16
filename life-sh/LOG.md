# life-sh build log

- Picked Conway's Game of Life because it fits in awk's associative arrays and needs no libraries.
- Wrote life.awk first with two arrays (cur and nxt) and a step function that counts the eight neighbours with bounds checks. Dead cells outside the grid, so no wrap-around.
- Wrote life.sh as a thin wrapper that validates the generation count and the grid path, then runs awk with `-v gens`.
- Wrote check.sh with the blinker, block and glider, then the bad-input cases and the sabotage copy.
- First run of check.sh: 13 ok lines and PASS, exit 0. A manual run on a 3x3 glider grid gave the expected generation 1 rows (`...`, `#.#`, `.##`).
- Nothing broke on the first run. The main risk was the sabotage sed: it only matches the birth line `nxt[r, c] = (n == 3)`, so check.sh tests that the edit applied before trusting the failure.
- Known limits: the grid is finite and not toroidal, and the whole grid is re-scanned each generation, so large grids are slow.
