# Log

- Wrote forth.c in one go. FizzBuzz printed "izz" and "uzz": the `."` handler skipped a char with `src++`, but the tokenizer had already consumed the space. Removed it.
- Loop ran wrong: `do` pushed limit and index to the return stack in swapped order. Fixed.
- Added check.sh with the expected output and two spot checks. Passes.
- Known gaps: no variables, no nested `j`, no bounds checks.
