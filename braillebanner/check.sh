#!/bin/sh
# Round-trip checks for hack/braillebanner.py. Exits 0 only if every check passes.
cd "$(dirname "$0")/.." || exit 1
python3 -B -I - "$PWD/hack/braillebanner.py" <<'EOF'
import subprocess, sys

path = sys.argv[1]
sys.path.insert(0, path.rsplit("/", 1)[0])
import braillebanner as bb

failures = []


def check(name, ok, detail=""):
    if not ok:
        failures.append(f"{name}: {detail}")
    print(("ok   " if ok else "FAIL ") + name)


def run(*args, stdin=b""):
    p = subprocess.run([sys.executable, path, *args], input=stdin,
                       capture_output=True)
    return p.returncode, p.stdout.decode("utf-8"), p.stderr.decode("utf-8")


samples = [
    "hello world",
    "Goblin Council",
    "Skrunkle, 5 times!",
    "a1b2 c3",
    "Hi? Yes-no.",
    "ABC xyz 0 9",
    "The quick brown fox jumps over the lazy dog 1234567890.",
]
for s in samples:
    cells = bb.encode(s)
    check(f"library round trip {s!r}", bb.decode(cells) == s, bb.decode(cells))
    rc, out, _ = run("encode", s)
    check(f"cli encode {s!r}", rc == 0 and cells in out, out)
    rc2, dec, _ = run("decode", stdin=out.encode("utf-8"))
    check(f"cli decode {s!r}", rc2 == 0 and dec == s + "\n", dec)

rc, out, _ = run("encode", "hi")
lines = out.splitlines()
check("banner shape", rc == 0 and len(lines) == 3
      and lines[0].startswith("+") and lines[1].startswith("| ")
      and lines[1].endswith(" |") and lines[2] == lines[0], out)

check("letter a is dot 1", bb.encode("a") == "\u2801", repr(bb.encode("a")))
check("digit 1 is number sign then a", bb.encode("1") == "\u283c\u2801",
      repr(bb.encode("1")))
check("capital A is capital sign then a", bb.encode("A") == "\u2820\u2801",
      repr(bb.encode("A")))
check("digit run ends with terminator",
      bb.encode("12 a") == "\u283c\u2801\u2803\u2830\u2800\u2801",
      repr(bb.encode("12 a")))

rc, _, err = run("encode", "@")
check("unsupported char exits 1", rc == 1 and "braillebanner" in err, err)
rc, _, _ = run("frobnicate")
check("bad usage exits 2", rc == 2, str(rc))

if failures:
    print(f"{len(failures)} failed")
    sys.exit(1)
print("PASS")
EOF
