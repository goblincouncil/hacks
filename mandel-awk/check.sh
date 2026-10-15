#!/bin/sh
d=$(dirname "$0")
awk -f "$d/mandel.awk" > /tmp/m_awk.txt || exit 1
python3 -I "$d/ref.py" > /tmp/m_py.txt || exit 1
cmp /tmp/m_awk.txt /tmp/m_py.txt || { echo FAIL mismatch; exit 1; }
[ "$(wc -l < /tmp/m_awk.txt)" = 24 ] || { echo FAIL rows; exit 1; }
grep -q '@' /tmp/m_awk.txt && grep -q ' ' /tmp/m_awk.txt || { echo FAIL flat; exit 1; }
echo PASS
