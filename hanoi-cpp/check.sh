#!/bin/sh
# Checks hanoi.c: for 1 to 6 discs, gcc -E must print a legal move list
# that matches the reference solver, and a sabotaged list must be rejected.
set -e
cd "$(dirname "$0")"

python3 -I - <<'EOF'
import re, subprocess, sys, tempfile, os

def solve(n, f='A', t='C', v='B'):
    if n == 0:
        return []
    return solve(n - 1, f, v, t) + [(f, t)] + solve(n - 1, v, t, f)

def expand(src, n):
    out = subprocess.run(['gcc', '-E', '-P', f'-DDISCS={n}', src],
                         capture_output=True, text=True, check=True).stdout
    return [(a, b) for a, b in re.findall(r'"([ABC])"\s*"->"\s*"([ABC])"', out)]

def legal(n, moves):
    """Simulate on three pegs. Return True only if every move is legal and all discs end on C."""
    pegs = {'A': list(range(n, 0, -1)), 'B': [], 'C': []}
    for src, dst in moves:
        if src == dst or not pegs[src]:
            return False
        disc = pegs[src][-1]
        if pegs[dst] and pegs[dst][-1] < disc:
            return False
        pegs[dst].append(pegs[src].pop())
    return pegs['C'] == list(range(n, 0, -1)) and not pegs['A'] and not pegs['B']

fails = 0
for n in range(1, 7):
    moves = expand('hanoi.c', n)
    ref = solve(n)
    ok = moves == ref and len(moves) == 2 ** n - 1 and legal(n, moves)
    print(f'discs={n} moves={len(moves)} matches_reference={moves == ref} legal={legal(n, moves)}')
    if not ok:
        fails += 1

# Sabotage: the first move starts from empty peg B, which must be rejected.
for n in range(1, 7):
    moves = solve(n)
    bad = moves[:]
    bad[0] = ('B', bad[0][1])
    if legal(n, bad):
        print(f'sabotage not caught for discs={n}')
        fails += 1

# Sabotage: a dropped move must be rejected.
if legal(3, solve(3)[:-1]):
    print('dropped move not caught')
    fails += 1

if fails:
    print('FAIL')
    sys.exit(1)
print('PASS')
EOF
