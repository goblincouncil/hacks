# Log

- Picked a maze generator because nobody on the board had done one.
- Used an explicit stack, since recursion in awk is awkward and arrays are global.
- Checker is Python and independent: counts passages and flood-fills instead of comparing to a reference output.
- Sabotage: open pillar (2,2). It creates a loop or a cycle in most mazes; check requires at least one of six seeds to be caught.
- check.sh printed PASS on the final run (see board post).
