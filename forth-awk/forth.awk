# forth-awk: a small Forth. Compiles to a flat op array, then runs it.
BEGIN { n = 0; sp = 0; rp = 0; cp = 0; lp = 0 }
function die(m) { print "?: " m > "/dev/stderr"; bad = 1; exit 1 }
function emit(o, a) { op[n] = o; arg[n] = a; n++ }
function pop() { if (sp < 1) die("stack underflow"); return st[sp--] }
function push(v) { st[++sp] = v }
function bin(w,  b, a) {
  b = pop(); a = pop()
  if (w == "+") push(a + b); else if (w == "-") push(a - b)
  else if (w == "*") push(a * b)
  else if (w == "/" || w == "mod") {
    if (b == 0) die("divide by zero")
    push(w == "/" ? int(a / b) : a % b)
  } else if (w == "=") push(a == b ? -1 : 0)
  else if (w == "<") push(a < b ? -1 : 0)
  else if (w == ">") push(a > b ? -1 : 0)
  else if (w == "and") push(and(a, b)); else if (w == "or") push(or(a, b))
}
{ sub(/(^|[ \t])\\([ \t].*)?$/, ""); src = src " " $0 }
END {
  if (bad) exit 1
  t = split(tolower(src), tok, /[ \t]+/)
  for (k = 1; k <= t; k++) {
    w = tok[k]
    if (w == "") continue
    if (w == "(") { while (k < t && tok[k] !~ /\)$/) k++; continue }
    if (w == ".\"") {
      s = ""
      while (++k <= t) { if (tok[k] ~ /"$/) { s = s (s == "" ? "" : " ") substr(tok[k], 1, length(tok[k]) - 1); break } s = s (s == "" ? "" : " ") tok[k] }
      if (k > t) die("unterminated string")
      emit("STR", s)
    } else if (w ~ /^-?[0-9]+$/) emit("LIT", w + 0)
    else if (w == ":") { name = tok[++k]; emit("JMP", 0); defj = n - 1; dict[name] = n; indef = 1 }
    else if (w == ";") { if (!indef) die("; outside definition"); emit("RET", 0); arg[defj] = n; indef = 0 }
    else if (w == "if") { emit("JZ", 0); cs[++cp] = n - 1 }
    else if (w == "else") { emit("JMP", 0); arg[cs[cp]] = n; cs[cp] = n - 1 }
    else if (w == "then") { if (cp < 1) die("then without if"); arg[cs[cp--]] = n }
    else if (w == "begin") cs[++cp] = n
    else if (w == "until") { if (cp < 1) die("until without begin"); emit("JZ", cs[cp--]) }
    else if (w == "do") { emit("DO", 0); cs[++cp] = n }
    else if (w == "loop") { if (cp < 1) die("loop without do"); emit("LOOP", cs[cp--]) }
    else if (w in dict) emit("CALL", dict[w])
    else if (w ~ /^(\+|-|\*|\/|mod|=|<|>|and|or|dup|drop|swap|over|rot|\.|cr|emit|negate|1\+|1-|0=|i)$/) emit("P", w)
    else die("unknown word " w)
  }
  if (indef || cp > 0) die("unbalanced definition or control")
  emit("HALT", 0)
  for (pc = 0; ; ) {
    o = op[pc]; a = arg[pc]; pc++
    if (o == "HALT") break
    else if (o == "LIT") push(a)
    else if (o == "STR") printf "%s", a
    else if (o == "JMP") pc = a
    else if (o == "JZ") { if (pop() == 0) pc = a }
    else if (o == "CALL") { rs[++rp] = pc; pc = a }
    else if (o == "RET") pc = rs[rp--]
    else if (o == "DO") { s = pop(); l = pop(); lp++; ix[lp] = s; lm[lp] = l }
    else if (o == "LOOP") { if (++ix[lp] < lm[lp]) pc = a; else lp-- }
    else if (a == "dup") { x = pop(); push(x); push(x) }
    else if (a == "drop") pop()
    else if (a == "swap") { y = pop(); x = pop(); push(y); push(x) }
    else if (a == "over") { y = pop(); x = pop(); push(x); push(y); push(x) }
    else if (a == "rot") { z = pop(); y = pop(); x = pop(); push(y); push(z); push(x) }
    else if (a == ".") printf "%d ", pop()
    else if (a == "cr") printf "\n"
    else if (a == "emit") printf "%c", pop()
    else if (a == "negate") push(-pop())
    else if (a == "1+") push(pop() + 1)
    else if (a == "1-") push(pop() - 1)
    else if (a == "0=") push(pop() == 0 ? -1 : 0)
    else if (a == "i") push(ix[lp])
    else bin(a)
  }
}
