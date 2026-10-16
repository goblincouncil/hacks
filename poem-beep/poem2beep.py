#!/usr/bin/env python3
"""poem-beep: turn a text file of nonsense poetry into a square-wave WAV.

usage: poem2beep.py POEM.txt OUT.wav [NOTES.txt]

Each letter a-z is one note. Its pitch is its place in a 24-step scale
(a=0 ... x=23, y and z wrap to 0 and 1). Vowels last longer than
consonants. Space, comma, period and line break are rests. Other
characters are skipped. Output is 8 kHz, 16-bit, mono.
"""
import struct
import sys
import wave

RATE = 8000
AMP = 9000
BASE_HZ = 220.0  # A3, the floor of the poem
SCALE = 24       # two octaves of semitones
NOTE_MS = {True: 150, False: 90}  # keyed by is-vowel
REST_MS = {' ': 40, ',': 120, '.': 260, '\n': 220}
REST_NAME = {' ': 'space', ',': 'comma', '.': 'period', '\n': 'newline'}


def events(text):
    for ch in text.lower():
        if 'a' <= ch <= 'z':
            semi = (ord(ch) - ord('a')) % SCALE
            ms = NOTE_MS[ch in 'aeiou']
            yield ('note', ch, semi, BASE_HZ * 2 ** (semi / 12), ms)
        elif ch in REST_MS:
            yield ('rest', REST_NAME[ch], 0, 0.0, REST_MS[ch])


def render(evs):
    out = []
    for kind, _, _, hz, ms in evs:
        n = int(RATE * ms / 1000)
        if kind == 'rest':
            out.extend([0] * n)
            continue
        phase, step = 0.0, hz / RATE
        for _ in range(n):
            out.append(AMP if phase < 0.5 else -AMP)
            phase = (phase + step) % 1.0
    return out


def main(argv):
    if len(argv) not in (3, 4):
        print('usage: poem2beep.py POEM.txt OUT.wav [NOTES.txt]', file=sys.stderr)
        return 2
    with open(argv[1], encoding='utf-8') as f:
        evs = list(events(f.read()))
    samples = render(evs)
    with wave.open(argv[2], 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(struct.pack('<%dh' % len(samples), *samples))
    if len(argv) == 4:
        with open(argv[3], 'w', encoding='utf-8') as f:
            for kind, name, semi, hz, ms in evs:
                if kind == 'note':
                    f.write('note %s %d %.2f %d\n' % (name, semi, hz, ms))
                else:
                    f.write('rest %s %d\n' % (name, ms))
    print('%d events, %d samples' % (len(evs), len(samples)))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
