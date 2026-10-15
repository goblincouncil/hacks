#!/usr/bin/env python3
"""Turn a short poem into a square-wave .wav in the style of a PC speaker.

Usage: python3 beeper.py POEM.txt OUT.wav [LOG.txt]

Rule: each word is one note. Its letters pick the pitch, its vowels pick
the length, and the punctuation after it picks the rest. See README.md.
"""
import sys
import wave

RATE = 22050
UNIT = 0.09  # seconds per unit of note length
SCALE = [262, 294, 330, 392, 440, 523, 587, 660, 784, 880]  # C pentatonic, 2 octaves
VOWELS = set('aeiouy')
HI, LO, MID = 224, 32, 128  # 8-bit unsigned: square high, square low, silence
SHORT_REST = 0.04
LONG_REST = 0.22
TINY_REST = 0.02
SHORT_MARKS = set(',;:-')
LONG_MARKS = set('.?!')


def words_of(text):
    """Yield (word, first trailing mark) for each word in the poem."""
    for raw in text.split():
        core = raw.rstrip(',;:.?!-')
        mark = raw[len(core):][:1]
        core = ''.join(c for c in core if c.isalpha())
        if core:
            yield core, mark


def notes_of(text):
    """Return a list of (freq_hz, seconds, rest_seconds, word, mark)."""
    notes = []
    for word, mark in words_of(text):
        low = word.lower()
        freq = SCALE[sum(ord(c) for c in low) % len(SCALE)]
        units = 1 + sum(1 for c in low if c in VOWELS)
        if mark in LONG_MARKS:
            rest = LONG_REST
        elif mark in SHORT_MARKS:
            rest = SHORT_REST
        else:
            rest = TINY_REST
        notes.append((freq, units * UNIT, rest, word, mark))
    return notes


def render(notes):
    """Return 8-bit mono samples: one square wave per note, then silence."""
    out = bytearray()
    for freq, dur, rest, _, _ in notes:
        for i in range(int(dur * RATE)):
            # floor(2 * i * freq / RATE) ticks once per half cycle
            phase = (2 * i * freq) // RATE
            out.append(HI if phase % 2 == 0 else LO)
        out.extend(bytes([MID]) * int(rest * RATE))
    return bytes(out)


def write_wav(path, samples):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(1)
        w.setframerate(RATE)
        w.writeframes(samples)


def log_text(text, notes):
    lines = ['poem:']
    lines += ['  ' + line for line in text.strip().splitlines()]
    lines.append('notes: %d' % len(notes))
    t = 0.0
    for freq, dur, rest, word, _ in notes:
        lines.append('%7.3fs  %-12s %4d Hz  %.2fs  rest %.2fs' % (t, word, freq, dur, rest))
        t += dur + rest
    lines.append('total: %.2fs' % t)
    return '\n'.join(lines) + '\n'


def main(argv):
    if len(argv) < 3:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    with open(argv[1], encoding='utf-8') as f:
        text = f.read()
    notes = notes_of(text)
    if not notes:
        print('no words in poem', file=sys.stderr)
        return 1
    write_wav(argv[2], render(notes))
    log = log_text(text, notes)
    if len(argv) > 3:
        with open(argv[3], 'w', encoding='utf-8') as f:
            f.write(log)
    else:
        sys.stdout.write(log)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
