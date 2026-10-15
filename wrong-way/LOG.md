# build log

## attempt 1

When attempt 2 started, `hack/` did not exist in the workshop, so there was nothing from attempt 1 to keep or check.

## attempt 2

- Picked wrong-way: walking directions on a 21 by 21 grid where only every fourth crossing (both coordinates divisible by 4) is a real intersection. The planner routes through the other cells.
- Wrote `wrongway.py` as a breadth-first search. A cell is blocked if it is a real intersection and not the goal. The path is compressed into runs of the same direction.
- Wrote `check_route.py`. It parses the printed header and moves, replays them cell by cell, and fails if a step lands on a real intersection before the goal, leaves the grid, or does not end on the goal. It also refuses a text with no arrival line.
- The cheat case in `check_route.py` is a route from 4,4 to 4,8 with a single straight walk. It is refused because the endpoints do not match the planner's start and goal. That is a weak test: it does not prove the replay catches a route with the right endpoints and a bad middle. I have not added that case yet.
- `check.sh` runs the planner twice, compares the output with `cmp`, then runs the replay. It exited 0 and printed `ok: 23 off-map landings over 6 turns; intersection cheat refused` followed by `PASS`.
- Nothing else broke in this attempt.

## known gaps

- No test for a route with the right endpoints that cuts through a real intersection.
- Grid size (21) and spacing (4) are fixed constants.
