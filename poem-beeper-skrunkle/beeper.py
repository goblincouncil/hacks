#!/usr/bin/env python3
'''Render a poem-score to an 8-bit mono square-wave WAV file.

Score lines are NOTE BEATS REST. NOTE is a name like C4, C#5, Bb3, or - for
a silent note. BEATS is how long the note sounds, REST is the silence after
it, both in beats. 'tempo N' sets beats per minute. A ';' starts a comment.
The comment text is the poem; it is printed next to each note in the log.
'''
import sys
import wave

RATE = 8000
LETTERS = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
HIGH, LOW, MID = 200, 56, 128


def pitch_hz(name):
    if name == '-':
        return None
    if not name or name[0].upper() not in LETTERS:
        raise ValueError(f'bad note {name!r}')
    semis = LETTERS[name[0].upper()]
    i = 1
    while i < len(name) and name[i] in '#b':
        semis += 1 if name[i] == '#' else -1
        i += 1
    try:
        octave = int(name[i:])
    except ValueError:
        raise ValueError(f'bad note {name!r}') from None
    return 440.0 * 2 ** (((octave + 1) * 12 + semis - 69) / 12)


def parse(text):
    tempo, notes, verse = 120.0, [], ''
    for lineno, raw in enumerate(text.splitlines(), 1):
        code, _, comment = raw.partition(';')
        if comment.strip():
            verse = comment.strip()
        parts = code.split()
        if not parts:
            continue
        if parts[0] == 'tempo' and len(parts) == 2:
            tempo = float(parts[1])
            if tempo <= 0:
                raise ValueError(f'line {lineno}: tempo must be > 0')
            continue
        if len(parts) != 3:
            raise ValueError(f'line {lineno}: want NOTE BEATS REST, got {code.strip()!r}')
        note, beats, rest = parts[0], float(parts[1]), float(parts[2])
        pitch_hz(note)
        if beats <= 0 or rest < 0:
            raise ValueError(f'line {lineno}: beats must be > 0 and rest >= 0')
        notes.append((lineno, note, beats, rest, verse))
    return tempo, notes


def render(tempo, notes):
    beat = 60.0 / tempo
    out, log = bytearray(), []
    for lineno, note, beats, rest, verse in notes:
        hz = pitch_hz(note)
        n = round(beats * beat * RATE)
        if hz is None:
            out += bytes([MID]) * n
            where = 'silent'
        else:
            half = RATE / hz / 2
            out += bytes(HIGH if int(i / half) % 2 == 0 else LOW for i in range(n))
            where = f'{hz:.1f} Hz'
        out += bytes([MID]) * round(rest * beat * RATE)
        log.append(f'{lineno:>3} {note:<5} {beats:g} beats {where:>10} rest {rest:g} | {verse}')
    return out, log


def write_wav(path, samples):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(1)
        w.setframerate(RATE)
        w.writeframes(bytes(samples))


def main(argv):
    if len(argv) != 3:
        print('usage: beeper.py poem.txt out.wav', file=sys.stderr)
        return 2
    try:
        with open(argv[1]) as f:
            tempo, notes = parse(f.read())
        samples, log = render(tempo, notes)
    except (OSError, ValueError) as e:
        print(f'beeper: {e}', file=sys.stderr)
        return 1
    write_wav(argv[2], samples)
    for line in log:
        print(line)
    print(f'wrote {argv[2]}: {len(samples) / RATE:.2f} s, {len(notes)} notes')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
