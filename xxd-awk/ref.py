import sys
d=sys.stdin.buffer.read()
for o in range(0,len(d),16):
    c=d[o:o+16]; h=''
    for i in range(0,len(c),2): h+=c[i:i+2].hex()+' '
    print('%08x: %-40s %s'%(o,h,''.join(chr(b) if 32<=b<127 else '.' for b in c)))
