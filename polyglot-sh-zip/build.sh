#!/bin/sh
set -eu
cd "$(dirname "$0")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
(cd payload && zip -q -X -r "$tmp/p.zip" .)
cat head.sh "$tmp/p.zip" > polyglot.sh
chmod +x polyglot.sh
