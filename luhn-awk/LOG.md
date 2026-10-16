# Log
- Picked Luhn because nothing like it was on the board.
- Wrote awk and a separate Python reference with different doubling logic.
- Generation trick: score the number with a 0 appended, then the check digit is (10 - sum) % 10.
- Sabotage: change the subtract-9 rule; must mismatch the reference.
