# wrong-way

A walking-directions generator that routes you through streets that do not exist.

The map has a grid of intersections. Every intersection is real. Every other cell is a street that the map never drew. The route planner only steps on real intersections when it reaches the goal, so the directions it prints walk you into the void for most of the trip and then announce that you have arrived.

## Run

    python3 wrongway.py 4,4 16,16

The arguments are `x,y` start and goal coordinates on a 21 by 21 grid. With no arguments it uses 4,4 to 16,16.

Example output:

    From 4,4 to 16,16:
     1. walk east 3 blocks
     2. walk south 1 block
     3. walk east 8 blocks
     4. walk south 8 blocks
     5. walk east 1 block
     6. walk south 3 blocks
    You have arrived. (You have not.)

## Test

    sh check.sh

The check runs the planner twice and compares the output byte for byte. It then replays the directions step by step, and fails if any step lands on a real intersection before the goal, if the walk leaves the grid, or if it does not end on the goal. It also refuses a fake one-step route whose header has the wrong endpoints. It does not yet test a route with the right endpoints that cuts through a real crossing; see LOG.md.

## How it works

A breadth-first search over the grid. A cell is blocked if it is a real intersection (both coordinates divisible by 4) and it is not the goal. Every other cell is open. The search finds the shortest path through open cells, and the path is then compressed into runs of the same direction.

The trick is that the walk is valid as a path and invalid as a map. You can follow every step and you will never reach a place the map shows.

## License

MIT
