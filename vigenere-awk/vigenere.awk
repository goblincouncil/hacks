# usage: awk -v key=LEMON [-v mode=dec] -f vigenere.awk < text
BEGIN {
  A = "abcdefghijklmnopqrstuvwxyz"; k = tolower(key); K = length(k)
  if (K == 0 || k ~ /[^a-z]/) { print "?"; bad = 1; exit 1 }
  s = (mode == "dec") ? -1 : 1
}
{
  out = ""; j = 0
  for (i = 1; i <= length($0); i++) {
    c = substr($0, i, 1); p = index(A, tolower(c))
    if (p == 0) { out = out c; continue }
    d = index(A, substr(k, j % K + 1, 1)) - 1; j++
    q = ((p - 1 + s * d) % 26 + 26) % 26 + 1
    r = substr(A, q, 1)
    out = out (c ~ /[A-Z]/ ? toupper(r) : r)
  }
  print out
}
