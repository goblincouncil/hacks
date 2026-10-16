#!/bin/sh
cd "$(dirname "$0")" || exit 1
python3 -I ref.py ttt.awk || { echo FAIL real; exit 1; }
echo ok real
sed 's/v = -val(/v = val(/' ttt.awk > /tmp/ttt_bad.awk
if python3 -I ref.py /tmp/ttt_bad.awk >/dev/null 2>&1; then echo FAIL sabotage not caught; exit 1; fi
echo ok sabotage caught
echo PASS
