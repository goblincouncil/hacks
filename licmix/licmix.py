#!/usr/bin/env python3
"""licmix: can code under two licenses ship together? Offline, stdlib only.
Not legal advice. Exit 0 ok, 1 incompatible, 2 unknown license."""
import sys

ORDER = ["MIT", "BSD-2-Clause", "BSD-3-Clause", "ISC", "Unlicense", "CC0-1.0",
         "Apache-2.0", "MPL-2.0", "LGPL-3.0-or-later", "LGPL-3.0-only",
         "GPL-2.0-or-later", "GPL-2.0-only", "GPL-3.0-or-later",
         "GPL-3.0-only", "AGPL-3.0-or-later", "AGPL-3.0-only"]
PERMISSIVE = ORDER[:6]
G3 = ["GPL-3.0-or-later", "GPL-3.0-only"]
A3 = ["AGPL-3.0-or-later", "AGPL-3.0-only"]
L3 = ["LGPL-3.0-or-later", "LGPL-3.0-only"]
# FLOW[x] = licenses a work containing x-licensed code may be released under
FLOW = {p: set(ORDER) for p in PERMISSIVE}
FLOW["Apache-2.0"] = {"Apache-2.0", "MPL-2.0", *L3, *G3, *A3}
FLOW["MPL-2.0"] = {"MPL-2.0", "GPL-2.0-or-later", "GPL-2.0-only", *L3, *G3, *A3}
FLOW["LGPL-3.0-or-later"] = {*L3, *G3, *A3}
FLOW["LGPL-3.0-only"] = {"LGPL-3.0-only", "GPL-3.0-only", "AGPL-3.0-only"}
FLOW["GPL-2.0-or-later"] = {"GPL-2.0-or-later", "GPL-2.0-only", *G3, *A3}
FLOW["GPL-2.0-only"] = {"GPL-2.0-only"}
FLOW["GPL-3.0-or-later"] = {*G3, *A3}
FLOW["GPL-3.0-only"] = {"GPL-3.0-only", "AGPL-3.0-only"}
FLOW["AGPL-3.0-or-later"] = set(A3)
FLOW["AGPL-3.0-only"] = {"AGPL-3.0-only"}

ALIAS = {"GPL-2.0": "GPL-2.0-only", "GPL-3.0": "GPL-3.0-only",
         "GPL-2.0+": "GPL-2.0-or-later", "GPL-3.0+": "GPL-3.0-or-later",
         "AGPL-3.0": "AGPL-3.0-only", "AGPL-3.0+": "AGPL-3.0-or-later",
         "LGPL-3.0": "LGPL-3.0-only", "LGPL-3.0+": "LGPL-3.0-or-later",
         "APACHE2": "Apache-2.0", "APACHE-2": "Apache-2.0", "BSD": "BSD-3-Clause",
         "UNLICENSE": "Unlicense", "CC0": "CC0-1.0"}

def norm(s):
    k = s.strip().upper()
    if k in ALIAS:
        return ALIAS[k]
    for o in ORDER:
        if o.upper() == k:
            return o
    return None

def mix(a, b):
    both = FLOW[a] & FLOW[b]
    if not both:
        return None
    mine = [x for x in (a, b) if x in both]
    if mine:
        return max(mine, key=ORDER.index)
    return min(both, key=ORDER.index)

def box(line):
    bar = "+" + "-" * (len(line) + 2) + "+"
    return "\n".join([bar, "| " + line + " |", bar])

def main(argv):
    if len(argv) != 2:
        print("usage: licmix.py LICENSE_A LICENSE_B   (SPDX ids)", file=sys.stderr)
        return 2
    a, b = norm(argv[0]), norm(argv[1])
    for raw, n in zip(argv, (a, b)):
        if n is None:
            print("licmix: unknown license %r; known: %s" % (raw, ", ".join(ORDER)), file=sys.stderr)
            return 2
    r = mix(a, b)
    if r is None:
        print(box("%s + %s: NO, no license can carry both" % (a, b)))
        return 1
    note = " (keep both notices)" if r in PERMISSIVE or r == "Apache-2.0" else " (whole work under it)"
    print(box("%s + %s: OK, ship as %s%s" % (a, b, r, note)))
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
