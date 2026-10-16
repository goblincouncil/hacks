import sys
def ok(s):
    t=0
    for i,c in enumerate(reversed(s)):
        d=int(c)
        if i%2: d=d*2-9 if d>4 else d*2
        t+=d
    return t%10==0
for l in sys.stdin:
    l=l.strip()
    if l.startswith("gen "):
        n=l[4:]
        print(next(n+str(c) for c in range(10) if ok(n+str(c))))
    elif l.isdigit(): print(l,"ok" if ok(l) else "bad")
    else: print(l,"?")
