#!/usr/bin/env python3
"""Plays every possible human game against spoilsport.sed and checks it never loses.

The human tries every legal move at every turn, both when the human opens and
when spoilsport opens. sed is called once per ply with every live board on its
own line, so the whole game tree takes a handful of sed runs.

Usage: referee.py path/to/spoilsport.sed
Prints a summary; exits 0 only if spoilsport never loses and never cheats.
"""
import os
import shlex
import subprocess
import sys

LINES = [(0, 1, 2), (3, 4, 5), (6, 7, 8),
         (0, 3, 6), (1, 4, 7), (2, 5, 8),
         (0, 4, 8), (2, 4, 6)]


def winner(b):
    for a, c, d in LINES:
        if b[a] != '.' and b[a] == b[c] == b[d]:
            return b[a]
    return None


def ask(script, boards):
    if not boards:
        return {}
    sed = shlex.split(os.environ.get('SED', 'sed'))
    out = subprocess.run(sed + ['-f', script], input='\n'.join(boards) + '\n',
                         capture_output=True, text=True, check=True).stdout
    replies = out.split('\n')[:-1]
    if len(replies) != len(boards):
        raise SystemExit('FAIL: %d boards in, %d lines out' % (len(boards), len(replies)))
    return dict(zip(boards, replies))


def main():
    script = sys.argv[1]
    errors = []
    results = {'O': 0, 'X': 0, 'draw': 0}
    # A position is a board where it is spoilsport's turn. Track how many
    # human move sequences reach it so the game count is honest.
    frontier = {'.........': 1}
    for i in range(9):
        b = ['.'] * 9
        b[i] = 'X'
        frontier[''.join(b)] = 1
    while frontier:
        replies = ask(script, sorted(frontier))
        nxt = {}
        for board, ways in frontier.items():
            reply = replies[board]
            after = reply[:9]
            tail = reply[9:]
            diff = [i for i in range(9) if board[i] != after[i]]
            if len(after) != 9 or len(diff) != 1 or board[diff[0]] != '.' or after[diff[0]] != 'O':
                errors.append('%s -> %r is not one legal O move' % (board, reply))
                continue
            w = winner(after)
            full = '.' not in after
            want = ' spoilsport wins' if w == 'O' else (' draw' if full else '')
            if tail != want:
                errors.append('%s -> %r, expected tail %r' % (board, reply, want))
            if w == 'O':
                results['O'] += ways
                continue
            if full:
                results['draw'] += ways
                continue
            for i in range(9):
                if after[i] != '.':
                    continue
                h = after[:i] + 'X' + after[i + 1:]
                if winner(h) == 'X':
                    results['X'] += ways
                    errors.append('human wins: %s' % h)
                elif '.' not in h:
                    results['draw'] += ways
                else:
                    nxt[h] = nxt.get(h, 0) + ways
        frontier = nxt
    total = sum(results.values())
    print('games played: %d' % total)
    print('spoilsport won: %d' % results['O'])
    print('drawn: %d' % results['draw'])
    print('human won: %d' % results['X'])
    for e in errors[:10]:
        print('FAIL ' + e)
    if errors or results['X'] or total == 0:
        sys.exit(1)


if __name__ == '__main__':
    main()
