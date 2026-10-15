#!/bin/sh
set -u
cd "$(dirname "$0")" || exit 1
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

sh build.sh || { echo "FAIL: build"; exit 1; }

# 1. starts as a shell script
if head -n 1 polyglot.sh | grep -qx '#!/bin/sh'; then ok starts-as-shell; else bad starts-as-shell; fi

# 2. zip local header present after the script
zoff=$(python3 -I -c 'import sys; print(open(sys.argv[1],"rb").read().find(b"PK\x03\x04"))' polyglot.sh)
if [ "$zoff" -gt 0 ]; then ok zip-magic-at-$zoff; else bad zip-magic; fi

# 3. sh runs it and stops before the binary part
out=$(sh polyglot.sh 2>/dev/null); rc=$?
if [ $rc -eq 0 ]; then ok sh-exit-0; else bad sh-exit-$rc; fi
echo "$out" | grep -q 'shell script' && ok sh-message || bad sh-message
size=$(printf '%s' "$out" | wc -c)
if [ "$size" -lt 200 ]; then ok sh-output-small-$size; else bad sh-output-big; fi

# 4. unzip lists the payload
unzip -l polyglot.sh 2>/dev/null | grep -q 'note.txt' && ok unzip-lists || bad unzip-lists

# 5. extract via sh and compare with source
rm -rf /tmp/polyglot-check.$$
sh polyglot.sh extract /tmp/polyglot-check.$$ >/dev/null 2>&1
if cmp -s /tmp/polyglot-check.$$/note.txt payload/note.txt; then ok extract-matches; else bad extract-matches; fi
rm -rf /tmp/polyglot-check.$$

# 6. sabotage: a copy with the exit removed must not be accepted as fine
# (sh then reads binary; its output must differ from the good run)
tmpd=$(mktemp -d)
sed '/^exit 0$/d' polyglot.sh > "$tmpd/bad.sh"
bad_out=$(sh "$tmpd/bad.sh" 2>/dev/null; echo rc=$?)
rm -rf "$tmpd"
case "$bad_out" in *'shell script'*rc=0*) bad sabotage-not-caught ;; *) ok sabotage-caught ;; esac

[ $fail -eq 0 ] && echo PASS || echo FAIL
exit $fail
