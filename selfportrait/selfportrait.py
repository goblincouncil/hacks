s='''import sys,zlib
Q=chr(39)*3
src='s='+Q+s+Q+chr(10)+s
K=4;H=8
rows=src.split(chr(10))
if rows[-1]=='':rows.pop()
W=max(len(r) for r in rows)
raw=b''
for r in rows:
 b=r.encode('ascii').ljust(W,bytes(1))
 raw+=(bytes(1)+bytes(c for c in b for k in range(K)))*H
def col(i):
 c=chr(i)
 if i==0:return (20,12,28)
 if i==32:return (52,24,60)
 if 97<=i<=122:return (255,127-(i-97)*2,80+(i-97)*5)
 if 65<=i<=90:return (255,200,(i-65)*9)
 if 48<=i<=57:return (40,200,180+(i-48)*5)
 if c in '()[]{}':return (170,110,255)
 if c in '"'+chr(39):return (255,105,180)
 if c in '+-*/=<>%,.:;':return (255,170,40)
 return (90,150,255)
def ch(t,d):return len(d).to_bytes(4,'big')+t+d+zlib.crc32(t+d).to_bytes(4,'big')
png=bytes([137])+b'PNG'+bytes([13,10,26,10])
png+=ch(b'IHDR',(W*K).to_bytes(4,'big')+(len(rows)*H).to_bytes(4,'big')+bytes([8,3,0,0,0]))
png+=ch(b'PLTE',b''.join(bytes(col(i)) for i in range(256)))
png+=ch(b'tEXt',b'scale'+bytes(1)+('%dx%d'%(K,H)).encode())
png+=ch(b'IDAT',zlib.compress(raw,9))
png+=ch(b'IEND',b'')
sys.stdout.buffer.write(png)
'''
import sys,zlib
Q=chr(39)*3
src='s='+Q+s+Q+chr(10)+s
K=4;H=8
rows=src.split(chr(10))
if rows[-1]=='':rows.pop()
W=max(len(r) for r in rows)
raw=b''
for r in rows:
 b=r.encode('ascii').ljust(W,bytes(1))
 raw+=(bytes(1)+bytes(c for c in b for k in range(K)))*H
def col(i):
 c=chr(i)
 if i==0:return (20,12,28)
 if i==32:return (52,24,60)
 if 97<=i<=122:return (255,127-(i-97)*2,80+(i-97)*5)
 if 65<=i<=90:return (255,200,(i-65)*9)
 if 48<=i<=57:return (40,200,180+(i-48)*5)
 if c in '()[]{}':return (170,110,255)
 if c in '"'+chr(39):return (255,105,180)
 if c in '+-*/=<>%,.:;':return (255,170,40)
 return (90,150,255)
def ch(t,d):return len(d).to_bytes(4,'big')+t+d+zlib.crc32(t+d).to_bytes(4,'big')
png=bytes([137])+b'PNG'+bytes([13,10,26,10])
png+=ch(b'IHDR',(W*K).to_bytes(4,'big')+(len(rows)*H).to_bytes(4,'big')+bytes([8,3,0,0,0]))
png+=ch(b'PLTE',b''.join(bytes(col(i)) for i in range(256)))
png+=ch(b'tEXt',b'scale'+bytes(1)+('%dx%d'%(K,H)).encode())
png+=ch(b'IDAT',zlib.compress(raw,9))
png+=ch(b'IEND',b'')
sys.stdout.buffer.write(png)
