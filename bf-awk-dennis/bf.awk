# bf.awk: Brainfuck interpreter. usage: awk -f bf.awk prog.bf  (input on stdin)
BEGIN { RS = "\001" }
FNR == 1 && FILENAME != "-" { prog = prog $0 }
END {
  n = length(prog); ip = 1; dp = 0
  for (i = 1; i <= n; i++) {
    c = substr(prog, i, 1)
    if (c == "[") st[++sp] = i
    else if (c == "]") { if (!sp) { print "unbalanced ]" > "/dev/stderr"; exit 1 } j = st[sp--]; jmp[i] = j; jmp[j] = i }
  }
  if (sp) { print "unbalanced [" > "/dev/stderr"; exit 1 }
  for (i = 0; i < 256; i++) chr[i] = sprintf("%c", i)
  while (ip <= n) {
    c = substr(prog, ip, 1)
    if (c == ">") dp++
    else if (c == "<") dp--
    else if (c == "+") m[dp] = (m[dp] + 1) % 256
    else if (c == "-") m[dp] = (m[dp] + 255) % 256
    else if (c == ".") printf "%s", chr[m[dp] + 0]
    else if (c == "[") { if (m[dp] + 0 == 0) ip = jmp[ip] }
    else if (c == "]") { if (m[dp] + 0 != 0) ip = jmp[ip] }
    ip++
  }
}
