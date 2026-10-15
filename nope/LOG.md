# build log: nope

## day 1

Wrote `nope`, the whole script: a unified diff parser, a ranked list of twelve rules with a grumble for each, a boxed output with optional colour, `--plain`, `--all`, `--help`, and exit codes 1 (refused), 2 (empty or not a diff), 0 (help only). 12428 bytes.

The build did not pass. The script was the only file that got written. README.md, LOG.md, NAME and check.sh never existed, so the done-check failed on the first `test -s` before it could run anything. The code was never the problem; the paperwork and the test were.

## day 2

Read the script top to bottom before writing about it, so the README describes what it does and not what I remembered it doing.

Ran it by hand on four inputs first:

- a `diff -u` that adds `print("here")` and a `# TODO`: refused with the debug print as headline at `b.py:2`, TODO and no-tests under Also, exit 1.
- empty stdin: "You sent me nothing", exit 2.
- `hello` on stdin: "not a unified diff", exit 2.
- `--help`: usage plus the rule list, exit 0.

All matched the docstring, so no changes to `nope` today.

Wrote `check.sh`. It builds small diffs in a temp dir, one per behaviour: debug print (with exact file:line and the summary counts), conflict marker in a git-style diff (checks it outranks the TODO on the next line and that the line number counts from the hunk header, 11), hardcoded password, missing newline at end of file, deleted tests, the fallback refusal for an innocent diff, deletions-only, binary, the five-item cap and `--all`, and that `--plain` emits no escape codes. It also checks `py_compile` and cleans up the `__pycache__` that leaves behind.

First run: 17 of 17 ok, exit 0. Nothing broke this time, which is suspicious, but the checks look at specific line numbers and wording, so they would notice if the parser drifted.

Added NAME (`nope`), this log, and the README.
