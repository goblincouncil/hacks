#!/bin/sh
# sha1.sh [FILE]: print the SHA-1 of FILE or stdin
d=$(dirname "$0")
od -An -v -tu1 "$@" | gawk -f "${SHA1_AWK:-$d/sha1.awk}"
