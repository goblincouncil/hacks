import sys
key, mode = sys.argv[1].lower(), sys.argv[2]
s = -1 if mode == "dec" else 1
for line in sys.stdin.read().split("\n")[:-1]:
    o = []; j = 0
    for ch in line:
        if ch.isascii() and ch.isalpha():
            b = 65 if ch.isupper() else 97
            o.append(chr((ord(ch) - b + s * (ord(key[j % len(key)]) - 97)) % 26 + b)); j += 1
        else: o.append(ch)
    print("".join(o))
