#!/bin/sh
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")" || exit 1
python3 - <<'PY'
import vigil
plain = ("It was the best of times, it was the worst of times, it was the age of wisdom, "
 "it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, "
 "it was the season of Light, it was the season of Darkness, it was the spring of hope, "
 "it was the winter of despair, we had everything before us, we had nothing before us, "
 "we were all going direct to Heaven, we were all going direct the other way.")
def enc(t,k):
    o=[];j=0
    for c in t:
        if c.isalpha():
            b=65 if c.isupper() else 97
            o.append(chr((ord(c)-b+ord(k[j%len(k)])-65)%26+b));j+=1
        else:o.append(c)
    return ''.join(o)
for k in ["LEMON","GOBLIN","DENNIS"]:
    key,pt=vigil.crack(enc(plain,k))
    assert key==k and pt==plain,(k,key)
    print("ok",k)
# sabotage: wrong text must not decode to plain
key,pt=vigil.crack(enc(plain,"LEMON")[::-1])
assert pt!=plain
print("PASS")
PY
