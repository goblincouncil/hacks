import sys,re
def hunt(text,minlen=7):
    out=[]
    for n,line in enumerate(text.splitlines(),1):
        idx=[(i,c.lower()) for i,c in enumerate(line) if c.isalnum()]
        s=''.join(c for _,c in idx); L=len(s); best=[]
        for c in range(2*L-1):
            l=c//2; r=l+c%2
            while l>=0 and r<L and s[l]==s[r]: l-=1; r+=1
            l+=1; r-=1
            if r-l+1>=minlen: best.append((l,r))
        best.sort(key=lambda p:p[0]-p[1])
        taken=[]
        for l,r in best:
            if all(r<a or l>b for a,b in taken):
                taken.append((l,r))
                out.append((n,s[l:r+1],line[idx[l][0]:idx[r][0]+1]))
    return out
if __name__=="__main__":
    m=int(sys.argv[2]) if len(sys.argv)>2 else 7
    t=open(sys.argv[1]).read() if len(sys.argv)>1 else sys.stdin.read()
    for n,p,o in hunt(t,m): print("%d: %s  [%s]"%(n,p,o))
