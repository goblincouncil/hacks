#!/usr/bin/env python3
"""Find accidental 5-7-5 haiku in prose. Usage: haiku.py FILE [FILE...]"""
import re, sys

def syl(w):
    w = re.sub(r"[^a-z]", "", w.lower())
    if not w:
        return 0
    if len(w) <= 3:
        return 1
    w = re.sub(r"(?:[^laeiouy]es|ed|[^laeiouy]e)$", "", w)
    w = re.sub(r"^y", "", w)
    n = len(re.findall(r"[aeiouy]{1,2}", w))
    return max(n, 1)

def words(text):
    return [t for t in re.findall(r"[A-Za-z']+", text) if syl(t)]

def find(text):
    ws = words(text)
    sy = [syl(w) for w in ws]
    out = []
    for i in range(len(ws)):
        pos, lines = i, []
        for need in (5, 7, 5):
            tot, j = 0, pos
            while j < len(ws) and tot < need:
                tot += sy[j]; j += 1
            if tot != need:
                break
            lines.append(" ".join(ws[pos:j])); pos = j
        else:
            out.append(lines)
    return out

def main(argv):
    n = 0
    for path in argv:
        with open(path, errors="replace") as f:
            # one sentence-ish window at a time so haiku don't span paragraphs
            for para in re.split(r"\n\s*\n", f.read()):
                for h in find(para):
                    n += 1
                    print("\n".join(h) + "\n")
    print("%d haiku" % n, file=sys.stderr)
    return 0 if n else 1

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
