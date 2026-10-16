#!/bin/sh
# exits 0 only if poem-beeper round-trips a poem through a WAV and random text,
# and a copy with a broken decoder is caught.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec python3 -I - "$here" <<'PY'
import importlib.util, os, random, re, string, subprocess, sys, tempfile

here = sys.argv[1]
pb_path = os.path.join(here, "poem-beeper.py")
poem_path = os.path.join(here, "poem.txt")


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def norm(s):
    return re.sub(r"[^a-z0-9]", " ", s.lower())


def through_wav(mod, text, d):
    wav = os.path.join(d, "t.wav")
    mod.write_wav(wav, mod.encode_text(text))
    return mod.decode_samples(mod.read_wav(wav))


pb = load(pb_path, "pb")
run = [sys.executable, "-I", pb_path]

# 1. CLI round trip on the poem
with tempfile.TemporaryDirectory() as d:
    wav = os.path.join(d, "poem.wav")
    r = subprocess.run(run + ["encode", poem_path, wav])
    assert r.returncode == 0, "encode exit %d" % r.returncode
    r = subprocess.run(run + ["decode", wav], capture_output=True, text=True)
    assert r.returncode == 0, "decode exit %d" % r.returncode
    got = r.stdout[:-1] if r.stdout.endswith("\n") else r.stdout
    want = norm(open(poem_path, encoding="utf-8").read())
    assert got == want, "poem mismatch:\n%r\n%r" % (got, want)
    print("ok cli poem round trip,", len(want), "notes")

# 2. random text through the WAV path
rng = random.Random(15)
alpha = string.ascii_letters + string.digits + " .,;!?\n"
for _ in range(300):
    s = "".join(rng.choice(alpha) for _ in range(rng.randint(1, 120)))
    with tempfile.TemporaryDirectory() as d:
        got = through_wav(pb, s, d)
    assert got == norm(s), "random mismatch: %r -> %r" % (s, got)
print("ok 300 random strings through wav")

# 3. a copy with a broken decoder must not round-trip
src = open(pb_path, encoding="utf-8").read()
bad_src = src.replace(
    "i = round((t - 0.2 * BASE_HZ) / (0.2 * STEP_HZ))",
    "i = round((t - 0.2 * BASE_HZ) / (0.2 * (STEP_HZ + 1)))")
assert bad_src != src, "sabotage did not apply"
text = "abcdefghijklmnopqrstuvwxyz0123456789"
with tempfile.TemporaryDirectory() as d:
    bad = os.path.join(d, "bad.py")
    with open(bad, "w", encoding="utf-8") as f:
        f.write(bad_src)
    got = through_wav(load(bad, "bad"), text, d)
    assert got != norm(text), "sabotaged decoder was not caught"
print("ok sabotaged decoder caught")
print("PASS")
PY
