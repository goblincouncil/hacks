# nope

A command-line reviewer that refuses every diff you give it. It always says no, but it tells you why, and the why comes from what the diff actually does: the file, the line number on the new side, and the text it objects to.

## Run it

You need Python 3. Nothing else.

    git diff | ./nope
    diff -u old.py new.py | ./nope --plain
    git show HEAD | ./nope --all

- `--plain` turns off colour, even on a terminal.
- `--all` lists every complaint instead of the worst five.
- `--help` prints usage and the full rule list.

Exit status: 1 when it refuses (always, for any real diff), 2 when stdin is empty or not a diff, 0 only for `--help`.

Example:

    +-----------------------------------------------------------------------+
    | NOPE.                                                                 |
    |                                                                       |
    | b.py:2 leaves a debug print in: `print("here")`. The logs did not ask |
    | for your feelings.                                                    |
    |                                                                       |
    | Also:                                                                 |
    |   - TODO / FIXME / XXX / HACK in an added line (b.py:3)               |
    |   - code changed but no test file touched (b.py)                      |
    |                                                                       |
    | Reviewed 1 file, +2 -0. Refused.                                      |
    +-----------------------------------------------------------------------+

## How it works

`nope` is one Python file. It parses the unified diff on stdin (git style with `diff --git` headers, or plain `diff -u`) and keeps, per file, the added lines with their new-side line numbers, the removed lines, whether the file is binary, and whether it ends without a newline.

Then it walks a written list of rules, worst first: merge conflict markers, secrets (AWS keys, private keys, GitHub tokens, `password = "..."`), leftover debug prints and breakpoints, TODO/FIXME, missing trailing newline, deleted tests, code changed with no test touched, trailing whitespace, mixed tab and space indents, binary files, and diffs over 400 lines. The first rule that fires becomes the headline; up to four more go under "Also".

The one trick: it never runs out of reasons. If no rule fires, the fallback picks the longest added line and says it still doesn't like it. If the diff only deletes, it accuses you of hiding evidence. A clean diff is refused as firmly as a dirty one.

`check.sh` feeds it a set of small diffs, one per rule, and checks the exit code, the headline, the file and line it points at, the five-item cap, `--all`, and that `--plain` emits no escape codes.

    sh check.sh

Written by beans of the goblincouncil.

MIT License.
