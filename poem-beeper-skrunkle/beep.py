#!/usr/bin/env python3
'''beep: compile a poem into a square-wave tune.

usage: python3 beep.py POEM OUT.wav

A poem is a text file. Plain lines are verse, one bar each. A line that
starts with a number is a BASIC-flavoured statement. The only statement is
    10 TEMPO 140
Anything else is a compile error that names its line number. The build log
goes to stdout: the poem again, with every note under it.
'''
import array
import re
import sys
import wave

RATE = 22050
AMP = 9000
SCALE = [0, 2, 4, 7, 9]  # major pentatonic, in semitones
BASE_HZ = 110.0          # A2
VOWELS = set('aeiou')
STMT = re.compile('^([0-9]+) +([^ ]+)(?: +([^ ]+))? *$')
WORD = re.compile("[A-Za-z']+|[,;.!?]")


class CompileError(Exception):
    pass


def word_pitch(word):
    total = sum(ord(c) for c in word if c.isalpha())
    octave, degree = divmod(total % 15, len(SCALE))
    return BASE_HZ * 2 ** ((SCALE[degree] + 12 * octave) / 12.0)


def word_ms(word, tempo):
    vowels = sum(1 for c in word.lower() if c in VOWELS)
    return min(400, 90 + 60 * vowels) * 120.0 / tempo


def compile_poem(text):
    tempo = 120
    lines = []
    for n, raw in enumerate(text.splitlines(), 1):
        line = raw.strip()
        if not line:
            continue
        if line[0].isdigit():
            m = STMT.match(line)
            if not m or m.group(2).upper() != 'TEMPO' or not (m.group(3) or '').isdigit():
                raise CompileError('line %d: bad statement: %s' % (n, line))
            tempo = int(m.group(3))
            if not 30 <= tempo <= 300:
                raise CompileError('line %d: tempo %d is outside 30-300' % (n, tempo))
            lines.append((n, line, []))
            continue
        events = []
        for tok in WORD.findall(line):
            if tok in ',;':
                events.append((None, 120.0 * 120 / tempo, tok))
            elif tok in '.!?':
                events.append((None, 300.0 * 120 / tempo, tok))
            else:
                events.append((word_pitch(tok), word_ms(tok, tempo), tok))
        events.append((None, 80.0 * 120 / tempo, ''))  # bar end
        lines.append((n, line, events))
    return lines


def render(lines):
    out = []
    for _, _, events in lines:
        for hz, ms, _ in events:
            n = int(RATE * ms / 1000.0)
            if hz is None:
                out.extend([0] * n)
                continue
            period = RATE / hz
            out.extend(AMP if (i % period) < period / 2 else -AMP for i in range(n))
    return out


def write_wav(path, samples):
    pcm = array.array('h', samples)
    if sys.byteorder == 'big':
        pcm.byteswap()
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())


def print_log(lines):
    for n, line, events in lines:
        notes = ['%s(%.0fHz)' % (lbl, hz) if hz else lbl
                 for hz, _, lbl in events if lbl]
        print('%3d  %s' % (n, line))
        print('     ' + ' '.join(notes))


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    try:
        with open(argv[1], encoding='utf-8') as f:
            lines = compile_poem(f.read())
    except (OSError, UnicodeDecodeError, CompileError) as e:
        print('beep: %s' % e, file=sys.stderr)
        return 1
    print_log(lines)
    write_wav(argv[2], render(lines))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
