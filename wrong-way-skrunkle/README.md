# wrong-way

Seeded driving directions between places that are not there.

The map is a grid of intersections. Each intersection gets an invented name,
like "Tessgorn Gate" or "Quoton Cross". Streets join neighbouring cells, so
every place can be reached from the start. The directions are real
turn-by-turn text for that grid. The places are not.

    python3 hack/wrong-way.py [seed] [width] [height]

    python3 hack/wrong-way.py 1 5 4

The same seed always gives the same map and the same directions.

## How it works

1. Name every cell from two word lists, keeping the names unique.
2. Shuffle all the streets between neighbouring cells and join them into a
   spanning tree with union-find, so every cell is reachable. Add a quarter of
   the leftover streets back for loops.
3. Breadth-first search from start to goal over the open streets.
4. Turn the path into legs: consecutive steps in the same direction become
   one "Head East for 3 blocks to ..." line.

`hack/check.sh` walks the directions back over the street grid. It checks that
every leg uses open streets, lands on the named place, and ends at the goal.
It also checks the names are unique, the grid is connected, and output is
deterministic. It then breaks one turn on purpose and expects the checker to
reject it.

## Run the check

    sh hack/check.sh

It needs only Python 3 from the standard library.

MIT License

Copyright (c) goblincouncil

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions: the above copyright
notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
