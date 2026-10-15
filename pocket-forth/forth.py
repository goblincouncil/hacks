import sys
def expand(toks):
    defs, out, i = {}, [], 0
    while i < len(toks):
        t = toks[i]
        if t == ':':
            name = toks[i+1]; j = i+2; body = []
            while toks[j] != ';': body.append(toks[j]); j += 1
            defs[name] = [x for b in body for x in (defs[b] if b in defs else [b])]
            i = j+1
        else:
            out += defs[t] if t in defs else [t]; i += 1
    return out
def compile_(toks):
    code, st = [], []
    for t in expand(toks):
        if t == 'if': st.append(len(code)); code.append(['jz', None])
        elif t == 'else':
            k = st.pop(); st.append(len(code)); code.append(['jmp', None]); code[k][1] = len(code)
        elif t == 'then': code[st.pop()][1] = len(code)
        elif t == 'begin': st.append(len(code))
        elif t == 'until': code.append(['jz', st.pop()])
        else: code.append(['w', t])
    if st: raise SyntaxError('unclosed control word')
    return code
B = {'+': lambda a, b: a+b, '-': lambda a, b: a-b, '*': lambda a, b: a*b,
     '/': lambda a, b: a//b, 'mod': lambda a, b: a % b,
     '=': lambda a, b: -(a == b), '<': lambda a, b: -(a < b), '>': lambda a, b: -(a > b)}
def run(src):
    code, s, pc = compile_(src.replace('\n', ' ').split()), [], 0
    while pc < len(code):
        op, a = code[pc]; pc += 1
        if op == 'jmp': pc = a
        elif op == 'jz':
            if not s.pop(): pc = a
        elif a in B: y = s.pop(); x = s.pop(); s.append(B[a](x, y))
        elif a == 'dup': s.append(s[-1])
        elif a == 'drop': s.pop()
        elif a == 'swap': s[-2:] = [s[-1], s[-2]]
        elif a == 'over': s.append(s[-2])
        elif a == '.': print(s.pop(), end=' ')
        elif a == 'emit': print(chr(s.pop()), end='')
        elif a == 'cr': print()
        else:
            try: s.append(int(a))
            except ValueError: raise NameError('unknown word: ' + a)
if __name__ == '__main__':
    try: run(open(sys.argv[1]).read() if len(sys.argv) > 1 else sys.stdin.read())
    except Exception as e: print('error:', e, file=sys.stderr); sys.exit(1)
