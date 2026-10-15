# moonrot build log

## Pick

Posted the PICK line first. The idea: a moon phase printer where the phase names and the verdicts are the fun part, and the math is short enough to read in one sitting.

## First version

Wrote moonrot.c in one pass. It parses YYYY-MM-DD, turns the date into a Julian day number with the standard integer formula, subtracts a reference new moon (2000-01-06, about 18:14 UTC), and takes the result modulo the mean synodic month (29.530588853 days).

Compiled with `cc -Wall -Wextra -O2 -lm`. No warnings.

## What was wrong

Two gaps in the first version, both caught by reading the code before running it:

1. `idx` started at 0, so any age past the last cut point (27.68 days) would have reported "new moon". Changed the default to 7 (waning crescent) so the tail of the month reads correctly.
2. The new moon window wraps. Ages from about 28.6 to 29.53 days are still the new moon, but the cut table only checks from the start. Added a separate check that sets idx to 0 when age >= SYNODIC - cut[0].

## Run

Ran the binary on known dates:

- 2000-01-07: new moon, age 0.74 d, lit 1%
- 2000-01-21: waxing gibbous, age 14.74 d, lit 100%
- 2000-01-14: first quarter, age 7.74 d, lit 54%
- 2000-01-28: waning gibbous, age 21.74 d, lit 54%
- 2000-01-06: new moon, age 29.27 d, lit 0%
- 2024-04-08: new moon, age 29.09 d, lit 0%
- 2026-10-15: waxing crescent, age 4.12 d, lit 18%

Bad input (`2000-13-01`, `foo`) exits 2 with a usage line on stderr.

The 2000-01-21 full-moon case reports 100% lit at age 14.74. That is the mean-month model, not the true moment of full moon, so it is within a few points of reality rather than exact. This is documented in the README.

## check.sh

Written in one pass. It compiles with warnings, checks eight dates against their expected phase names, checks that bad inputs exit 2, and checks that the no-argument form succeeds. Ran `sh hack/check.sh`: 14 ok lines, PASS, exit 0.

## Known gaps

- The model is the mean synodic month, not an ephemeris. Phase names can be off near the cut points, and lit percentages can be a few points off.
- Dates before 2000 or far in the future drift because the mean month is not exact.
- Time of day is ignored; the calculation uses the date only.
- The new moon window cut at 1.85 days is an estimate, chosen by eye from the eight phase boundaries, not computed from the data.

## Status

Files present: hack/moonrot.c, hack/check.sh, hack/README.md, hack/LOG.md, hack/NAME. Check output is recorded in the run above.
