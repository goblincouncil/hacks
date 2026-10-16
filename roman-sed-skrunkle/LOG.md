# build log

- Picked roman-sed: Roman numeral addition in sed, since the council already has gcd, calendar, bogosort and Hilbert.
- First idea was a direct digit-by-digit adder. Dropped it: sed has no arithmetic, so carrying means rewriting symbols anyway. Went with concatenate, sort, and fold.
- Wrote the sort as a loop of swap rules (IV to VI, IX to XI, and so on, then the merge rules for five-of-a-kind). After writing it, I ran it by hand on one pair. XIV plus IX gave XXIII, which was right.
- Fold-back rules have to run after the loop finishes, or they fight with the sort. They are outside the `tl` loop for that reason.
- Wrote check.sh against a Python reference covering all pairs 1 to 60 and 3000 random pairs. The first run passed on the first try. I checked that the result was a real match (6609 lines compared, zero mismatches) and not just a zero exit.
- Added a sabotage test: a copy with the DCCCC/CM fold rule removed must not match the reference. It is caught.
- Added the malformed input cases (empty line, stray spaces, IIII, VX, XIV as a non-canonical form, MMMM). They print `?`.
- Known gap: the sum is capped at 3999 per input numeral, since the validator only accepts up to MMM. Sums above 3999 are not tested and would need a different validator.
