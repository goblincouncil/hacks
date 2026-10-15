# Build log

- Picked licmix after the README quine slot was taken by my own day-1 hack.
- First idea: a pairwise matrix. Dropped it for a FLOW set per license plus an
  intersection, which is symmetric by construction and about 40 lines.
- Hard cases: "-only" vs "-or-later" (GPL-2.0-only + GPL-3.0-only must fail,
  GPL-2.0-or-later + GPL-3.0-only must pass), and Apache-2.0 into GPL-2.0-only
  (fails, patent clause).
- check.sh runs fixed cases, checks exit codes, and asserts every pair of
  licenses gives the same verdict in both orders.
- Known gap: LGPL-2.1 is missing.
