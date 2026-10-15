#!/bin/sh
d=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || d=hack
t() { # a b exitcode expected-substring
  out=$(python3 "$d/licmix.py" "$1" "$2" 2>&1); rc=$?
  [ "$rc" = "$3" ] || { echo "FAIL $1 $2: exit $rc want $3"; exit 1; }
  case "$out" in *"$4"*) ;; *) echo "FAIL $1 $2: output lacks '$4': $out"; exit 1;; esac
}
t MIT MIT 0 "ship as MIT"
t MIT Apache-2.0 0 "ship as Apache-2.0"
t mit gpl-3.0 0 "ship as GPL-3.0-only"
t Apache-2.0 GPL-3.0-only 0 "ship as GPL-3.0-only"
t Apache-2.0 GPL-2.0-only 1 "NO"
t GPL-2.0-only GPL-3.0-only 1 "NO"
t GPL-2.0-or-later GPL-3.0-only 0 "ship as GPL-3.0-only"
t GPL-3.0-only AGPL-3.0-only 0 "ship as AGPL-3.0-only"
t AGPL-3.0-only MIT 0 "ship as AGPL-3.0-only"
t MPL-2.0 GPL-2.0-only 0 "ship as GPL-2.0-only"
t MIT Nonsense 2 "unknown license"
t MIT "" 2 "unknown"
python3 "$d/licmix.py" MIT >/dev/null 2>&1; [ $? = 2 ] || { echo "FAIL usage"; exit 1; }
# symmetry over every pair
for a in $(python3 -c "import sys;sys.path.insert(0,'$d');import licmix;print(*licmix.ORDER)"); do
 for b in $(python3 -c "import sys;sys.path.insert(0,'$d');import licmix;print(*licmix.ORDER)"); do
  x=$(python3 "$d/licmix.py" $a $b | sed 's/^| \(.*\): \(.*\) |$/\2/;t;d'| head -1)
  y=$(python3 "$d/licmix.py" $b $a | sed 's/^| \(.*\): \(.*\) |$/\2/;t;d'| head -1)
  [ "$x" = "$y" ] || { echo "FAIL asymmetric $a $b: $x / $y"; exit 1; }
 done
done
echo "licmix: all checks pass"
