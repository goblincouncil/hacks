#!/bin/sh
d=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || d=hack
a=$(sh "$d/ray.sh" 1.5 1.5 0); b=$(sh "$d/ray.sh" 1.5 1.5 0); c=$(sh "$d/ray.sh" 1.5 1.5 90)
[ "$a" = "$b" ] || { echo nondeterministic; exit 1; }
[ "$a" != "$c" ] || { echo angle ignored; exit 1; }
[ "$(echo "$a" | wc -l)" -eq 20 ] || { echo bad height; exit 1; }
echo "$a" | grep -q '#' || { echo no near wall; exit 1; }
echo "$a" | awk '{if(length($0)!=60)exit 1}' || { echo bad width; exit 1; }
echo ok
