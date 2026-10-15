#!/bin/sh
# check.sh: exits 0 only if nope really refuses diffs the way it says it does.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
NOPE="$HERE/nope"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
fail=0

ok()  { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }

# run: feed file $1 to nope with extra args, capture output and status
run() {
    f=$1; shift
    python3 "$NOPE" --plain "$@" < "$f" > "$T/out" 2>&1
    rc=$?
}

expect() { # name, want_rc, grep pattern
    if [ "$rc" != "$2" ]; then bad "$1 (exit $rc, wanted $2)"; sed 's/^/     /' "$T/out"; return; fi
    if ! grep -q -- "$3" "$T/out"; then bad "$1 (no match for: $3)"; sed 's/^/     /' "$T/out"; return; fi
    ok "$1"
}

[ -f "$NOPE" ] || { echo "FAIL nope missing"; exit 1; }
python3 -m py_compile "$NOPE" 2>/dev/null && ok "compiles" || bad "compiles"
rm -rf "$HERE/__pycache__"

# --help exits 0 and lists the rules
python3 "$NOPE" --help > "$T/out" 2>&1; rc=$?
expect "help" 0 "the written list of rules"

# empty stdin -> 2
: > "$T/empty"; run "$T/empty"; expect "empty input" 2 "You sent me nothing"

# not a diff -> 2
echo "hello there" > "$T/junk"; run "$T/junk"; expect "not a diff" 2 "not a unified diff"

# debug print, with the right file and new-side line number
mkdir "$T/a" "$T/b"
printf 'def f():\n    return 1\n' > "$T/a/m.py"
printf 'def f():\n    print("here")\n    return 1\n' > "$T/b/m.py"
(cd "$T" && diff -u a/m.py b/m.py > d.diff)
run "$T/d.diff"; expect "debug print headline" 1 "m.py:2 leaves a debug print in"
grep -q "no test file touched" "$T/out" && ok "no-tests listed under Also" || bad "no-tests listed under Also"
grep -q "Reviewed 1 file, +1 -0. Refused." "$T/out" && ok "summary counts" || bad "summary counts"

# conflict marker outranks everything, via a git-style diff
cat > "$T/c.diff" <<'EOF'
diff --git a/x.txt b/x.txt
--- a/x.txt
+++ b/x.txt
@@ -10,2 +10,4 @@
 keep
+<<<<<<< HEAD
+mine TODO
+>>>>>>> theirs
EOF
run "$T/c.diff"; expect "conflict marker" 1 "x.txt:11 still has a merge conflict marker"

# secret
cat > "$T/s.diff" <<'EOF'
--- a/cfg.env
+++ b/cfg.env
@@ -1 +1,2 @@
 name=x
+password = "hunter2hunter2"
EOF
run "$T/s.diff"; expect "secret" 1 "cfg.env:2 hands out a hardcoded secret"

# missing newline at end of file
cat > "$T/n.diff" <<'EOF'
--- a/notes.md
+++ b/notes.md
@@ -1 +1,2 @@
 one
+two
\ No newline at end of file
EOF
run "$T/n.diff"; expect "no newline at eof" 1 "notes.md ends without a newline after line 2"

# deleting tests
cat > "$T/t.diff" <<'EOF'
--- a/tests/test_core.py
+++ b/tests/test_core.py
@@ -1,3 +1 @@
-def test_a():
-    assert 1
 def test_b(): pass
EOF
run "$T/t.diff"; expect "tests deleted" 1 "loses 2 line(s) of tests"

# a clean-looking diff still gets refused (fallback)
cat > "$T/f.diff" <<'EOF'
--- a/poem.txt
+++ b/poem.txt
@@ -1 +1,2 @@
 roses
+violets are blue
EOF
run "$T/f.diff"; expect "fallback refusal" 1 "poem.txt:2 adds .violets are blue. and I looked at it"

# only deletions
cat > "$T/del.diff" <<'EOF'
--- a/old.txt
+++ b/old.txt
@@ -1,2 +1 @@
 stay
-gone
EOF
run "$T/del.diff"; expect "deletions only" 1 "only deletes things"

# binary
cat > "$T/bin.diff" <<'EOF'
diff --git a/logo.png b/logo.png
index 1..2 100644
Binary files a/logo.png and b/logo.png differ
EOF
run "$T/bin.diff"; expect "binary" 1 "logo.png is a binary blob"

# --all shows more than five complaints, default caps and says so
: > "$T/many.diff"
printf -- '--- a/w.txt\n+++ b/w.txt\n@@ -1 +1,9 @@\n top\n' > "$T/many.diff"
i=1; while [ $i -le 8 ]; do printf '+line %s TODO \n' $i >> "$T/many.diff"; i=$((i+1)); done
run "$T/many.diff"; expect "cap at five" 1 "more. Run with --all"
run "$T/many.diff" --all
if grep -q "Run with --all" "$T/out"; then bad "--all lists everything"; else
    n=$(grep -c '^|   - ' "$T/out"); [ "$n" -ge 10 ] && ok "--all lists everything ($n)" || bad "--all lists everything ($n)"; fi

# --plain means no escape codes
run "$T/d.diff"
if grep -q "$(printf '\033')" "$T/out"; then bad "plain has no colour"; else ok "plain has no colour"; fi

# it never says yes: every real diff above exited 1
[ $fail -eq 0 ] && echo "all checks passed" || echo "some checks failed"
exit $fail
