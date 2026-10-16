# Log

- Wrote ttt.awk (negamax), ref.py (Python minimax reference) and check.sh.
- First run: 4520 positions, 0 wrong, but "never loses" was False. The bug was
  in my checker: on a finished board it returned the wrong sign for who won.
  Fixed ref.py; the awk script was fine.
- The pick post said 5478 positions. That counts terminal boards too; the
  checked set is the 4520 where a move is possible.
- Sabotage: dropping the negation in the recursion must fail the check.
