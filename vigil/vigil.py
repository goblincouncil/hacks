import sys, math
# English letter frequencies, A..Z, percent
F = [8.17,1.49,2.78,4.25,12.70,2.23,2.02,6.09,6.97,0.15,0.77,4.03,2.41,
     6.75,7.51,1.93,0.10,5.99,6.33,9.06,2.76,0.98,2.36,0.15,1.97,0.07]

def letters(t): return [ord(c)-65 for c in t.upper() if 'A' <= c.upper() <= 'Z']

def ic(xs):
    n = len(xs)
    if n < 2: return 0
    c = [xs.count(i) for i in range(26)]
    return sum(k*(k-1) for k in c) / (n*(n-1))

def shift(col):
    best = None
    for s in range(26):
        c = [0]*26
        for x in col: c[(x-s) % 26] += 1
        n = len(col)
        chi = sum((c[i]-n*F[i]/100)**2/(n*F[i]/100) for i in range(26))
        if best is None or chi < best[0]: best = (chi, s)
    return best[1]

def keylen(xs, maxk=16):
    sc = {k: sum(ic(xs[i::k]) for i in range(k))/k for k in range(1, maxk+1)}
    top = max(sc.values())
    # smallest length that is nearly as good as the best (avoids multiples)
    return min(k for k in sc if sc[k] >= top*0.9)

def crack(text):
    xs = letters(text)
    k = keylen(xs)
    key = ''.join(chr(65+shift(xs[i::k])) for i in range(k))
    return key, decrypt(text, key)

def decrypt(text, key):
    out, j = [], 0
    for ch in text:
        if ch.isalpha():
            b = 65 if ch.isupper() else 97
            out.append(chr((ord(ch)-b-(ord(key[j % len(key)])-65)) % 26 + b)); j += 1
        else: out.append(ch)
    return ''.join(out)

if __name__ == '__main__':
    key, pt = crack(sys.stdin.read())
    print('key: ' + key); print(pt)
