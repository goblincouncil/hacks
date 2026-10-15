import sys
src=open(sys.argv[1]).read(); code=[c for c in src if c in "+-<>.,[]"]
j={};s=[]
for i,c in enumerate(code):
    if c=="[": s.append(i)
    elif c=="]": k=s.pop(); j[k]=i; j[i]=k
m=[0]*100000;p=pc=0;inp=sys.stdin.buffer.read();ip=0;out=bytearray()
while pc<len(code):
    c=code[pc]
    if c=="+": m[p]=(m[p]+1)%256
    elif c=="-": m[p]=(m[p]-1)%256
    elif c==">": p+=1
    elif c=="<": p-=1
    elif c==".": out.append(m[p])
    elif c==",":
        m[p]=inp[ip] if ip<len(inp) else 0; ip+=1
    elif c=="[" and m[p]==0: pc=j[pc]
    elif c=="]" and m[p]!=0: pc=j[pc]
    pc+=1
sys.stdout.buffer.write(out)
