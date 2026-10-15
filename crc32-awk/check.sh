#!/bin/sh
# Compares crc32.awk against python's zlib on a set of inputs.
# Exits 0 only if every case matches and a sabotaged copy is caught.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
LC_ALL=C
export LC_ALL
python3 -I - "$here/crc32.awk" "$tmp" <<'EOF'
import os, random, subprocess, sys, zlib

awk_src, tmp = sys.argv[1], sys.argv[2]
random.seed(6)
cases = {
    "empty": b"",
    "one-byte": b"a",
    "newline-only": b"\n",
    "known-vector": b"123456789",
    "hello": b"hello world\n",
    "no-final-newline": b"The quick brown fox\njumps over\n\nthe lazy dog",
    "blank-lines": b"\n\n\nx\n\n",
    "high-bytes": bytes(range(128, 256)) + b"\n",
    "all-bytes": bytes(range(256)),
    "random-4k": bytes(random.randrange(256) for _ in range(4096)),
}

def run(src, path):
    p = subprocess.run(["awk", "-f", src, path], capture_output=True, text=True,
                       env=dict(os.environ, LC_ALL="C"))
    if p.returncode != 0:
        return None, p.stderr.strip()
    return p.stdout.strip(), ""

fails = 0
paths = {}
for name, data in cases.items():
    path = os.path.join(tmp, name)
    with open(path, "wb") as f:
        f.write(data)
    paths[name] = path
    want = "%08x" % zlib.crc32(data)
    got, err = run(awk_src, path)
    if got == want:
        print("ok   %s %s" % (name, got))
    else:
        fails += 1
        print("FAIL %s got=%s want=%s %s" % (name, got, want, err))

# sabotage: a copy with a wrong polynomial must not match zlib
bad = os.path.join(tmp, "bad.awk")
with open(awk_src) as f:
    src = f.read()
if "3988292384" not in src:
    print("FAIL polynomial constant not found")
    fails += 1
else:
    with open(bad, "w") as f:
        f.write(src.replace("3988292384", "3988292385"))
    got, _ = run(bad, paths["hello"])
    if got == "%08x" % zlib.crc32(cases["hello"]):
        print("FAIL sabotaged copy was not caught")
        fails += 1
    else:
        print("ok   sabotaged copy caught")

if fails:
    print("FAILED: %d" % fails)
    sys.exit(1)
print("PASS")
EOF
