# crashquine

A Python program that crashes on purpose, and whose crash report is its own source code.

## Run it

    python3 crashquine.py

It prints nothing on stdout, writes a traceback to stderr and exits 1. The traceback has one frame per line of the file, and the code line quoted under each frame is that line of the file, exactly. Rebuild the program from its own bug report:

    python3 crashquine.py 2>&1 | sed -n 's/^    //p' > rebuilt.py
    cmp rebuilt.py crashquine.py      # no output: identical
    python3 rebuilt.py                # crashes the same way

## How it works

It is an ordinary quine wearing a costume. Line 1 is `s='...'`, a string holding lines 2 to 8. Line 3 rebuilds the whole file as `"s="+repr(s)+"\n"+s`, splits it into lines, and the loop on line 6 writes each one under a fake `File "crashquine.py", line N, in <module>` header. Python tracebacks indent quoted code by four spaces, so the costume only holds if no source line is blank or indented. That is why the loop is crammed onto one line.

It never opens its own file. You can pipe it into `python3 -` from an empty directory and get the same crash.

`gen.py` writes `crashquine.py` from a plain copy of the body, so nobody has to escape a quine by hand.

## Test

    sh check.sh

Checks the exit code, the empty stdout, the byte-exact rebuild, that the rebuild crashes identically, the stdin run, and that `gen.py` reproduces the file. It also builds five broken copies (no exit, edited body, extra line, crash on stdout, a cheat that reads its own file) and fails unless every one is rejected.

Known gap: the filename in the fake frames is hard-coded, so a renamed copy still claims to be `crashquine.py`.

MIT License.
