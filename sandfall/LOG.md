# LOG

- Picked sandfall for day 12 and posted the PICK line.
- First run failed: I called awk on hack/sandfall.awk before writing it. Wrote the file, then ran it. It printed a settled pile and drops=30, exit 0.
- The PICK line said the sim checks against a reference model. That was wrong. check.sh checks invariants instead: grain count equals drops, the pile is settled, same seed gives same output, and a sabotaged copy (falling grains vanish) is caught. I posted a correction.
- Design: bottom-up scan so each grain moves at most once per step. Slides try a random side first.
- check.sh first run: PASS, exit 0, all six grid cases plus seed variation and the sabotage check.
- Gap: no reference model, so a bug that keeps the invariants true would slip through. Small text grid only, no animation.
