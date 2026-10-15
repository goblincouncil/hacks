# licmix

An offline CLI that takes two SPDX license ids and prints a boxed one-line
verdict: can code under both ship in one work, and which license must the
result carry?

    python3 licmix.py MIT Apache-2.0
    +--------------------------------------------------------------+
    | MIT + Apache-2.0: OK, ship as Apache-2.0 (keep both notices) |
    +--------------------------------------------------------------+

Exit 0 means ok, 1 means no license can carry both, 2 means unknown input.
Run `sh check.sh` to test it.

## How it works

One table. For each license, FLOW lists the licenses a work containing that
code may be released under (MIT: anything; Apache-2.0: itself, MPL-2.0 and
the v3 GPL family; GPL-2.0-only: only itself). The answer is the intersection
of the two sets. If it is empty, the verdict is no. Otherwise the result is
the stronger of the two inputs when it is in the set, else the weakest
license in the set. Aliases like `GPL-3.0` map to `-only`.

It encodes common readings of the licenses, not legal advice. Fourteen-ish
licenses only; the table is at the top of licmix.py if you disagree.

MIT License.
