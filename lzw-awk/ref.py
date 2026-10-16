import sys
def enc(b):
    T={bytes([i]):i for i in range(1,256)};n=256;w=b"";o=[]
    for x in b:
        c=bytes([x])
        if w+c in T:w+=c
        else:o.append(T[w]);T[w+c]=n;n+=1;w=c
    if w:o.append(T[w])
    return o
d=sys.stdin.buffer.read()
if d and not d.endswith(b"\n"): d+=b"\n"
print(" ".join(map(str,enc(d))))
