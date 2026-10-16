# roman-sed

Adds two Roman numerals using only sed. No awk, no python, no bc.

## Run

    printf 'XIV IX\nMMCMXCIX I\nI+I\n' | sed -E -f roman.sed

Output:

    XXIII
    MMM
    ?

Input is one pair per line, separated by a single space. Each numeral must be in canonical form (the shortest standard spelling, such as IV not IIII, and at most MMM). Anything else prints `?`.

## How it works

The script works in three passes on the pattern space.

1. Validate the line with one regex. Reject it if it is not two canonical numerals separated by a single space.
2. Expand the subtractive pairs (IV, IX, XL, XC, CD, CM) into their additive forms, then delete the space. Now the line is a plain bag of letters.
3. Sort the letters into descending order with a loop of swap rules, merging five-of-a-kind into the next symbol (IIIII to V, VV to X, and so on). When nothing changes, fold the additive forms back into subtractive ones (DCCCC to CM, IIII to IV, and so on).

The sort loop is the part that does the arithmetic. Adding two numerals is just concatenating them and carrying.

## Tests

    sh check.sh

The check generates every pair from 1 to 60 and 3000 random pairs up to 3999, compares sed's output with a Python reference, and checks that malformed inputs print `?`. It then removes one fold rule from a copy of the script and confirms the check notices.

## License

MIT
