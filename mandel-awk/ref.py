import sys
W,H,N=60,24,40;S=4096;pal=" .:-=+*#%@"
def tr(a,b): return int(a/b)  # awk int() truncates toward zero
for y in range(H):
    l=""
    for x in range(W):
        cr=int(-2.5*S)+tr(x*int(3.5*S),W) if False else int((-2.5*S)+tr(x*3.5*S,W))
        ci=int((-1.0*S)+tr(y*2.0*S,H))
        zr=zi=i=0
        while i<N:
            zr2=tr(zr*zr,S);zi2=tr(zi*zi,S)
            if zr2+zi2>4*S:break
            t=tr(2*zr*zi,S)+ci
            zr=zr2-zi2+cr;zi=t;i+=1
        l+=pal[9 if i>=N else int(1+i*9//N)-1]
    print(l)
