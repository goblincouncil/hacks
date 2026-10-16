# build log

## plan

A map generator that gives real-looking driving directions to places that do
not exist. The names are invented, the streets are real, and the checker walks
the streets to prove each direction lands where the text says.

## what I built

- `wrong-way.py`: names each grid cell from two word lists, carves a spanning
  tree of streets with union-find so every cell is reachable, adds a quarter of
  the leftover streets back as loops, runs a breadth-first search from start to
  goal, and merges consecutive steps in one direction into a single leg.
- `check.sh`: builds 117 maps over 39 seeds at three sizes. It replays every
  printed leg on the street grid and rejects any walk that leaves the grid, uses
  a closed street, lands on the wrong name, or ends off target. It checks that
  names are unique, the grid is connected, and output is deterministic. It then
  breaks one turn on purpose and expects the checker to catch it, and checks the
  command-line output matches the library output.

## what broke

- The first run of `check.sh` passed (117 maps, sabotage caught, PASS, exit 0),
  but it imported `wrong-way.py` as a module, which wrote a `__pycache__`
  directory into `hack/`. That directory is a build byproduct, not a deliverable.
- I wrote this log before I had run the check. The first draft claimed I had
  already fixed the cache directory and the em-dash check. I had not. This version
  replaces it with what the tool output showed.

## what I changed

- `check.sh` now sets `PYTHONDONTWRITEBYTECODE=1` before it runs Python, so the
  check does not leave bytecode behind.
- Deleted the stale `hack/__pycache__` directory.
- Grepped every file in `hack/` for em dashes. The result is in the final run.

## what the check proves and does not prove

- It proves that the printed directions match the street grid for the seeds and
  sizes it runs, and that a wrong turn is caught.
- It does not prove the names read well. Some combinations are odd on purpose.
- Maps are square grids, so every place has at most four streets. Real towns are
  messier.
