#!/usr/bin/env python3
"""poem-beeper: turn a text file into a square-wave WAV, one note per character.

usage:
  poem-beeper.py encode POEM.TXT OUT.WAV
  poem-beeper.py decode IN.WAV

Letters a-z and digits 0-9 each get their own pitch (220 Hz up to 920 Hz,
20 Hz apart, 0.1 s per note). Any other character is a rest. Decoding counts
the level changes in each 0.1 s slot and picks the nearest pitch.
"""
import re
import sys
import wave

RATE = 8000
NOTE_SAMPLES = 800          # 0.1 s per character
BASE_HZ = 220
STEP_HZ = 20
ALPHABET = "abcdefghijklmnopqrstuvwxyz0123456789"
HI, LO, MID = 200, 56, 128  # 8-bit unsigned PCM levels; MID is silence


def normalise(text):
    return re.sub(r"[^a-z0-9]", " ", text.lower())


def note_hz(i):
    return BASE_HZ + STEP_HZ * i


def encode_text(text):
    out = bytearray()
    for ch in normalise(text):
        if ch == " ":
            out += bytes([MID]) * NOTE_SAMPLES
            continue
        hz = note_hz(ALPHABET.index(ch))
        for n in range(NOTE_SAMPLES):
            phase = (n * hz / RATE) % 1.0
            out.append(HI if phase < 0.5 else LO)
    return bytes(out)


def transitions(seg):
    states = [s >= MID for s in seg]
    return sum(1 for a, b in zip(states, states[1:]) if a != b)


def decode_samples(data):
    chars = []
    for k in range(0, len(data) - NOTE_SAMPLES + 1, NOTE_SAMPLES):
        t = transitions(data[k:k + NOTE_SAMPLES])
        if t < 10:
            chars.append(" ")
            continue
        # a note at f Hz makes 0.2 * f transitions in 0.1 s
        i = round((t - 0.2 * BASE_HZ) / (0.2 * STEP_HZ))
        chars.append(ALPHABET[i] if 0 <= i < len(ALPHABET) else "?")
    return "".join(chars)


def write_wav(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(1)
        w.setframerate(RATE)
        w.writeframes(samples)


def read_wav(path):
    with wave.open(path, "rb") as w:
        if (w.getnchannels(), w.getsampwidth(), w.getframerate()) != (1, 1, RATE):
            raise SystemExit("expected mono 8-bit 8000 Hz WAV")
        return w.readframes(w.getnframes())


def main(argv):
    if len(argv) == 4 and argv[1] == "encode":
        with open(argv[2], encoding="utf-8") as f:
            write_wav(argv[3], encode_text(f.read()))
        return 0
    if len(argv) == 3 and argv[1] == "decode":
        sys.stdout.write(decode_samples(read_wav(argv[2])) + "\n")
        return 0
    sys.stderr.write(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
