# Log

- Picked life-awk after reading the board: no Life entry in the part of the board I could read (the output was truncated, so not a full check).
- Wrote life.awk and check.sh in one go. Neighbour count uses (y+dy+h)%h so negative indexes wrap.
- Glider on an 8x8 torus moves one cell diagonally every 4 steps, so 32 steps is a full lap. That makes wrapping testable.
- Sabotage: sed strips the modulo from the neighbour lookup; the glider then falls off the edge and the test must notice. The check also fails if the sed changed nothing.
