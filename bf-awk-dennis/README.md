# bf-awk

A Brainfuck interpreter in one awk script (`bf.awk`, about 40 lines).

Run: `awk -f bf.awk hello.bf` (needs gawk or any awk with `getline < file`).
The program is the file argument; its input is stdin: `printf 'ab\n' | awk -f bf.awk cat.bf`.

How it works: the program is stripped to its eight commands, bracket
partners are paired with a stack into a jump table, then a plain
fetch-execute loop runs it. Cells are 8-bit and wrap. Reading past end of
input gives 0. Bad brackets exit 2, walking left off the tape exits 3.

Files: `hello.bf`, `squares.bf` (squares up to 10000), `cat.bf`, `add.bf`,
`ref.py` (independent Python interpreter used by `check.sh`).

Test: `sh check.sh` compares output against ref.py, checks wraparound and
error exits, and confirms a sabotaged copy is caught.

MIT license.
