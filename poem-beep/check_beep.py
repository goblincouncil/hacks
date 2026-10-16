#!/usr/bin/env python3
"""Independent check for poem-beep.

usage: check_beep.py POEM.txt OUT.wav NOTES.txt

Re-derives the expected notes from the poem with its own copy of the
rules, then reads the WAV back. Checks the format, the total length,
that rests are silent, and that each note is a full-scale square wave
with the right number of half-cycles. The notes file must list the same
kinds, letters and scale steps in the same order.
"""
import struct
import sys
import wave

RATE = 8000
SCALE = 24
BASE = 220.0
NOTE_MS = {True: 150, False: 90}
REST_MS = {' ': 40, ',': 120, '.': 260, '\n': 220}


def expected(text):
    out = []
    for ch in text.lower():
        if 'a' <= ch <= 'z':
            semi = (ord(ch) - 97) % SCALE
            out.append(('note', ch, semi, BASE * 2 ** (semi / 12), NOTE_MS[ch in 'aeiou']))
        elif ch in REST_MS:
            out.append(('rest', ch, 0, 0.0, REST_MS[ch]))
    return out


def fail(msg):
    print('FAIL ' + msg)
    sys.exit(1)


def main(argv):
    if len(argv) != 4:
        print('usage: check_beep.py POEM.txt OUT.wav NOTES.txt')
        return 2
    with open(argv[1], encoding='utf-8') as f:
        evs = expected(f.read())
    with wave.open(argv[2], 'rb') as w:
        if (w.getnchannels(), w.getsampwidth(), w.getframerate()) != (1, 2, RATE):
            fail('format is not 8 kHz 16-bit mono')
        n = w.getnframes()
        s = struct.unpack('<%dh' % n, w.readframes(n))
    want = sum(int(RATE * ms / 1000) for *_, ms in evs)
    if n != want:
        fail('frames %d, expected %d' % (n, want))
    pos, notes = 0, 0
    for kind, ch, semi, hz, ms in evs:
        m = int(RATE * ms / 1000)
        seg = s[pos:pos + m]
        pos += m
        if kind == 'rest':
            if any(seg):
                fail('rest %r ending at frame %d is not silent' % (ch, pos))
            continue
        notes += 1
        amp = max(abs(v) for v in seg) if seg else 0
        if amp == 0 or any(abs(v) != amp for v in seg):
            fail('note %r ending at frame %d is not a square wave' % (ch, pos))
        signs = [v > 0 for v in seg]
        cross = sum(1 for a, b in zip(signs, signs[1:]) if a != b)
        if abs(cross - 2 * hz * m / RATE) > 1.5:
            fail('note %r has %d half-cycles, expected %.1f' % (ch, cross, 2 * hz * m / RATE))
    with open(argv[3], encoding='utf-8') as f:
        lines = [ln.split() for ln in f if ln.strip()]
    if len(lines) != len(evs):
        fail('notes file has %d lines, expected %d' % (len(lines), len(evs)))
    for parts, (kind, ch, semi, hz, ms) in zip(lines, evs):
        if parts[0] != kind:
            fail('notes kind mismatch: %s' % parts)
        if kind == 'note' and (parts[1] != ch or int(parts[2]) != semi):
            fail('notes letter or step mismatch: %s' % parts)
    print('OK %d notes, %d rests, %d frames' % (notes, len(evs) - notes, n))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
