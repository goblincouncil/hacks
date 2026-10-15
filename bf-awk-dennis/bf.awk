# bf.awk: Brainfuck interpreter. usage: awk -f bf.awk prog.bf [< input]
# prog is file arg; stdin is the program's input. 8-bit wrapping cells.
BEGIN {
  RS = "\001"; f = ARGV[1]; ARGV[1] = ""
  if ((getline src < f) <= 0) { print "bf.awk: cannot read program" > "/dev/stderr"; exit 2 }
  n = 0; sp = 0
  for (i = 1; i <= length(src); i++) {
    c = substr(src, i, 1)
    if (index("+-<>.,[]", c)) {
      code[++n] = c
      if (c == "[") st[++sp] = n
      else if (c == "]") {
        if (sp == 0) { print "bf.awk: unmatched ]" > "/dev/stderr"; exit 2 }
        j = st[sp--]; jmp[j] = n; jmp[n] = j
      }
    }
  }
  if (sp) { print "bf.awk: unmatched [" > "/dev/stderr"; exit 2 }
  for (i = 0; i < 256; i++) ord[sprintf("%c", i)] = i
  RS = "\n"; inbuf = ""; inpos = 1; eof = 0
  p = 0; pc = 1
  while (pc <= n) {
    c = code[pc]
    if (c == "+") m[p] = (m[p] + 1) % 256
    else if (c == "-") m[p] = (m[p] + 255) % 256
    else if (c == ">") p++
    else if (c == "<") { p--; if (p < 0) { print "bf.awk: pointer left tape" > "/dev/stderr"; exit 3 } }
    else if (c == ".") printf "%c", m[p]
    else if (c == ",") {
      if (inpos > length(inbuf)) {
        if (eof || (getline line) <= 0) { eof = 1; m[p] = 0; pc++; continue }
        inbuf = line "\n"; inpos = 1
      }
      m[p] = ord[substr(inbuf, inpos++, 1)]
    }
    else if (c == "[") { if (m[p] == 0) pc = jmp[pc] }
    else if (c == "]") { if (m[p] != 0) pc = jmp[pc] }
    pc++
  }
}
