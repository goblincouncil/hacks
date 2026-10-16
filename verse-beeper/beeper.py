#!/usr/bin/env python3
# verse-beeper: compile a verse into a BASIC-style listing, then play the
# listing as a square wave. Standard library only.
import struct
import sys
import wave

RATE = 8000
UNIT = 0.11  # seconds per duration unit
SCALE = [262, 294, 330, 392, 440, 523, 587, 659, 784, 880]
PUNCT_REST = {",": 1, ";": 1, ":": 1, ".": 3, "!": 3, "?": 3}
LINE_REST = 2
AMP = 12000


def tokens(line):
    word = ""
    for ch in line:
        if ch.isalpha() or ch == "'":
            word += ch.lower()
            continue
        if word:
            yield ("word", word)
            word = ""
        if ch in PUNCT_REST:
            yield ("rest", PUNCT_REST[ch])
    if word:
        yield ("word", word)


def compile_verse(text):
    out = []
    num = [10]

    def emit(body):
        out.append(f"{num[0]} {body}")
        num[0] += 10

    for line in text.splitlines():
        if not line.strip():
            continue
        emit(f"REM {line.strip()}")
        for kind, val in tokens(line):
            if kind == "word":
                freq = SCALE[sum(map(ord, val)) % len(SCALE)]
                units = 1 + len(val) % 3
                emit(f"SOUND {freq},{units}")
            else:
                emit(f"REST {val}")
        emit(f"REST {LINE_REST}")
    emit("END")
    return "\n".join(out) + "\n"


def parse(listing):
    events = []
    for raw in listing.splitlines():
        parts = raw.split(None, 2)
        if len(parts) < 2 or not parts[0].isdigit():
            raise ValueError(f"bad line: {raw!r}")
        cmd = parts[1]
        if cmd == "REM":
            continue
        if cmd == "END":
            break
        if cmd == "SOUND":
            freq, units = parts[2].split(",")
            events.append((int(freq), int(units)))
        elif cmd == "REST":
            events.append((0, int(parts[2])))
        else:
            raise ValueError(f"unknown command: {raw!r}")
    return events


def render(events, path):
    frames = bytearray()
    for freq, units in events:
        n = int(RATE * UNIT * units)
        if freq == 0:
            frames += bytes(n * 2)
            continue
        half = RATE / (2 * freq)
        for i in range(n):
            v = AMP if (i / half) % 2 < 1 else -AMP
            frames += struct.pack("<h", v)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(bytes(frames))


def main(argv):
    if len(argv) == 4 and argv[1] == "compile":
        with open(argv[2]) as f:
            listing = compile_verse(f.read())
        with open(argv[3], "w") as f:
            f.write(listing)
        return 0
    if len(argv) == 4 and argv[1] == "play":
        with open(argv[2]) as f:
            render(parse(f.read()), argv[3])
        return 0
    sys.stderr.write("usage: beeper.py compile poem.txt tune.bas\n"
                     "       beeper.py play tune.bas tune.wav\n")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
