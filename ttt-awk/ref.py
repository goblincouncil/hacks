import sys, subprocess
L=[(0,1,2),(3,4,5),(6,7,8),(0,3,6),(1,4,7),(2,5,8),(0,4,8),(2,4,6)]
def won(b,p): return any(all(b[i]==p for i in l) for l in L)
from functools import lru_cache
@lru_cache(None)
def v(b,p):  # value for p to move
    q='O' if p=='X' else 'X'
    if won(b,q): return -1
    if '.' not in b: return 0
    return max(-v(b[:i]+p+b[i+1:],q) for i in range(9) if b[i]=='.')
def moves(b):
    p='X' if b.count('X')==b.count('O') else 'O'; q='O' if p=='X' else 'X'
    return p,[i for i in range(9) if b[i]=='.' and -v(b[:i]+p+b[i+1:],q)==v(b,p)]
seen=set(); st=['.'*9]
while st:
    b=st.pop()
    if b in seen: continue
    seen.add(b)
    if won(b,'X') or won(b,'O') or '.' not in b: continue
    p='X' if b.count('X')==b.count('O') else 'O'
    for i in range(9):
        if b[i]=='.': st.append(b[:i]+p+b[i+1:])
awk=sys.argv[1]
live=sorted(b for b in seen if not(won(b,'X') or won(b,'O') or '.' not in b))
bad=["XX.......","O........","XXX.OO...","XO.","abc......","........."+"."]
inp="\n".join(live+bad)+"\n"
out=subprocess.run(["awk","-f",awk],input=inp,capture_output=True,text=True).stdout.split()
assert len(out)==len(live)+len(bad),"line count"
wrong=0
for b,o in zip(live,out):
    if o=="?" or int(o) not in moves(b)[1]: wrong+=1
for b,o in zip(bad,out[len(live):]):
    if o!="?": wrong+=1
# awk as each side never loses against any opponent
def play(b,side):
    o='O' if side=='X' else 'X'
    if won(b,o): return False
    if won(b,side): return True
    if '.' not in b: return True
    p='X' if b.count('X')==b.count('O') else 'O'
    if p==side:
        return play(b[:int(mv[b])]+p+b[int(mv[b])+1:],side)
    return all(play(b[:i]+p+b[i+1:],side) for i in range(9) if b[i]=='.')
mv=dict(zip(live,out))
nl=all(play('.'*9,s) for s in 'XO')
print(len(live),"positions, wrong",wrong,"never loses",nl)
sys.exit(0 if wrong==0 and nl else 1)
