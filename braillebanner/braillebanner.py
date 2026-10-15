#!/usr/bin/env python3
"""braillebanner: set short text as a Braille banner, and read it back.

Each letter, digit and punctuation mark is one six-dot Braille cell, using the
Grade 1 scheme (number sign for digits, capital sign, a terminator cell after
digits). The banner is those cells in an ASCII box. decode skips the box.
"""
import sys

BASE = 0x2800
NUMBER_SIGN = "3456"
CAPITAL = "6"
TERMINATOR = "56"
PUNCT = {" ": "", ".": "256", ",": "2", "?": "236", "!": "235", "-": "36"}
FIRST_TEN = ["1", "12", "14", "145", "15", "124", "1245", "125", "24", "245"]


def sorted_dots(dots):
    return "".join(sorted(dots))


def build():
    letters = {}
    for i, ch in enumerate("abcdefghij"):
        letters[ch] = FIRST_TEN[i]
        letters["klmnopqrst"[i]] = sorted_dots(FIRST_TEN[i] + "3")
    letters.update({"u": "136", "v": "1236", "w": "2456",
                    "x": "1346", "y": "13456", "z": "1356"})
    digits = {d: FIRST_TEN[i] for i, d in enumerate("1234567890")}
    chars = dict(letters)
    chars.update(PUNCT)
    values = list(chars.values())
    assert len(set(values)) == len(values), "braille table is not one-to-one"
    assert not {NUMBER_SIGN, CAPITAL, TERMINATOR} & set(values), "control cell collides"
    return letters, digits, chars


LETTERS, DIGITS, CHARS = build()
DIGIT_BY_DOTS = {v: k for k, v in DIGITS.items()}
CHAR_BY_DOTS = {v: k for k, v in CHARS.items()}


def cell(dots):
    return chr(BASE + sum(1 << (int(d) - 1) for d in dots))


def dots_of(ch):
    bits = ord(ch) - BASE
    return "".join(str(n + 1) for n in range(6) if (bits >> n) & 1)


def encode(text):
    dots, digit_run = [], False
    for ch in text:
        if ch in DIGITS:
            if not digit_run:
                dots.append(NUMBER_SIGN)
                digit_run = True
            dots.append(DIGITS[ch])
            continue
        if digit_run:
            dots.append(TERMINATOR)
            digit_run = False
        if ch in LETTERS:
            dots.append(LETTERS[ch])
        elif ch.isupper() and ch.lower() in LETTERS:
            dots += [CAPITAL, LETTERS[ch.lower()]]
        elif ch in PUNCT:
            dots.append(PUNCT[ch])
        else:
            raise ValueError(f"no braille for {ch!r}")
    return "".join(cell(d) for d in dots)


def decode(text):
    out, digit_run, capital = [], False, False
    for ch in text:
        if not BASE <= ord(ch) < BASE + 64:
            continue
        d = dots_of(ch)
        if d == NUMBER_SIGN:
            digit_run = True
        elif d == TERMINATOR:
            digit_run = False
        elif d == CAPITAL:
            capital = True
        elif digit_run and d in DIGIT_BY_DOTS:
            out.append(DIGIT_BY_DOTS[d])
        elif d in CHAR_BY_DOTS:
            c = CHAR_BY_DOTS[d]
            out.append(c.upper() if capital else c)
            capital = False
        else:
            raise ValueError(f"unknown braille cell {ch}")
    return "".join(out)


def banner(cells):
    edge = "+" + "-" * (len(cells) + 2) + "+"
    return "\n".join([edge, f"| {cells} |", edge])


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8")
    try:
        if len(argv) == 3 and argv[1] == "encode":
            print(banner(encode(argv[2])))
            return 0
        if len(argv) == 2 and argv[1] == "decode":
            print(decode(sys.stdin.buffer.read().decode("utf-8")))
            return 0
    except ValueError as err:
        print(f"braillebanner: {err}", file=sys.stderr)
        return 1
    print("usage: braillebanner.py encode TEXT | braillebanner.py decode < banner",
          file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
