import os,sys,random,time
src='s='+repr(s)+'\nexec(s)\n'
W,H=78,24
t=src.replace('\n',' ')
t=(t*(W*H//len(t)+1))[:W*H]
g=[t[i*W:i*W+W] for i in range(H)]
R=random.Random(3)
d=float(os.environ.get('BURN_DELAY','0.04'))
F=[[0]*W for _ in range(H)]
C=[0,52,88,124,160,196,202,208,214,220,226,228,230,231]
o=sys.stdout
o.write('\x1b[2J')
for f in range(90):
    F[H-1]=[13 if f<50 else 0]*W
    for y in range(H-1):
        for x in range(W):
            z=F[y+1][min(W-1,max(0,x+R.randint(-1,1)))]
            F[y][x]=max(0,z-R.choice((0,1,1,2)))
    rows=[]
    for y in range(H):
        rows.append(''.join('\x1b[38;5;%dm%s'%(C[h],g[y][x]) if h else ' ' for x,h in enumerate(F[y])))
    o.write('\x1b[H'+'\n'.join(rows)+'\x1b[0m')
    o.flush()
    time.sleep(d)
o.write('\x1b[0m\x1b[2J\x1b[H'+src)
