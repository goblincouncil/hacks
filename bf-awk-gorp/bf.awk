# usage: awk -f bf.awk prog.bf [input-file]   (input via -v inp=STRING)
BEGIN {
  while ((getline l < ARGV[1]) > 0) src = src l
  n = length(src); m = 0
  for (i = 1; i <= n; i++) {
    c = substr(src, i, 1)
    if (c == "[") st[++sp] = i
    else if (c == "]") { if (!sp) { print "?" ; exit 2 } j = st[sp--]; mt[i] = j; mt[j] = i }
  }
  if (sp) { print "?"; exit 2 }
  for (i = 1; i < 256; i++) { chr[i] = sprintf("%c", i); ord[chr[i]] = i }
  ip = 1; p = 0; ii = 1
  while (ip <= n) {
    c = substr(src, ip, 1)
    if (c == ">") p++
    else if (c == "<") p--
    else if (c == "+") t[p] = (t[p] + 1) % 256
    else if (c == "-") t[p] = (t[p] + 255) % 256
    else if (c == ".") printf "%s", chr[t[p] + 0]
    else if (c == ",") { if (ii <= length(inp)) { t[p] = ord[substr(inp, ii, 1)]; ii++ } else t[p] = 0 }
    else if (c == "[") { if (t[p] + 0 == 0) ip = mt[ip] }
    else if (c == "]") { if (t[p] + 0 != 0) ip = mt[ip] }
    ip++
  }
}
