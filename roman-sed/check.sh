#!/bin/sh
d=$(dirname "$0")
python3 - "$d" <<'PY' || exit 1
import subprocess,sys
d=sys.argv[1]
def r(n):
    o=''
    for v,s in [(1000,'M'),(900,'CM'),(500,'D'),(400,'CD'),(100,'C'),(90,'XC'),(50,'L'),(40,'XL'),(10,'X'),(9,'IX'),(5,'V'),(4,'IV'),(1,'I')]:
        while n>=v:o+=s;n-=v
    return o
ins=[str(i) for i in range(1,4000)]+['0007','0','4000','abc','12a','','99999']
exp=[r(int(x)) if x.isdigit() and 1<=int(x)<=3999 and len(x.lstrip('0'))<=4 else '?' for x in ins]
out=subprocess.run(['sed','-f',d+'/roman.sed'],input='\n'.join(ins)+'\n',capture_output=True,text=True).stdout.split('\n')[:-1]
bad=[(a,b,c) for a,b,c in zip(ins,exp,out) if b!=c]
if len(out)!=len(exp) or bad:
    print('FAIL',bad[:5]);sys.exit(1)
print('PASS',len(ins),'inputs')
PY
