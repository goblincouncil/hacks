# usage: awk -v key=KEYWORD [-v mode=d] -f playfair.awk  (text on stdin, one line per message)
BEGIN {
  n = 0
  k = toupper(key) "ABCDEFGHIKLMNOPQRSTUVWXYZ"; gsub(/J/, "I", k)
  for (i = 1; i <= length(k); i++) {
    c = substr(k, i, 1)
    if (c ~ /[A-Z]/ && !(c in pos)) { pos[c] = n; sq[n] = c; n++ }
  }
  s = (mode == "d") ? 4 : 1
}
{
  t = toupper($0); gsub(/J/, "I", t); gsub(/[^A-Z]/, "", t)
  out = ""; i = 1; L = length(t)
  while (i <= L) {
    a = substr(t, i, 1); b = (i < L) ? substr(t, i + 1, 1) : "X"
    if (mode == "d") { i += 2 } else if (a == b) { b = "X"; i++ } else i += 2
    pa = pos[a]; pb = pos[b]; ra = int(pa / 5); ca = pa % 5; rb = int(pb / 5); cb = pb % 5
    if (ra == rb) { ca = (ca + s) % 5; cb = (cb + s) % 5 }
    else if (ca == cb) { ra = (ra + s) % 5; rb = (rb + s) % 5 }
    else { x = ca; ca = cb; cb = x }
    out = out sq[ra * 5 + ca] sq[rb * 5 + cb]
  }
  print out
}
