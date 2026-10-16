import sys
for l in sys.stdin.read().split("\n")[:-1]:
    t=l+"\x01"; r=sorted(t[i:]+t[:i] for i in range(len(t)))
    print("".join(x[-1] for x in r).replace("\x01","$"))
