#!/bin/sh
# round trip 1..3999 against an independent Python converter, plus bad input
cd "$(dirname "$0")" || exit 1
python3 - <<'P' || exit 1
import subprocess
def rom(n):
    r=''
    for v,s in [(1000,'M'),(900,'CM'),(500,'D'),(400,'CD'),(100,'C'),(90,'XC'),(50,'L'),(40,'XL'),(10,'X'),(9,'IX'),(5,'V'),(4,'IV'),(1,'I')]:
        while n>=v: r+=s; n-=v
    return r
def run(lines):
    return subprocess.run(['sed','-E','-f','roman.sed'],input='\n'.join(lines)+'\n',capture_output=True,text=True,timeout=120).stdout.split('\n')[:-1]
ns=range(1,4000)
out=run([str(n) for n in ns])
assert out==[rom(n) for n in ns],'decimal to roman'
back=run([rom(n) for n in ns])
assert back==[str(n) for n in ns],'roman to decimal'
bad=['0','4000','IIII','IC','VX','abc','','00','12345','MMMM']
assert run(bad)==['?']*len(bad),run(bad)
print('ok 3999 each way, bad input refused')
P
# sabotage must be caught
sed 's/s\/IV\/IIII\//s\/IV\/IIIII\//' roman.sed > /tmp/rs_bad.sed
[ "$(echo IV | sed -E -f /tmp/rs_bad.sed)" != 4 ] || { echo sabotage missed; exit 1; }
echo PASS
