# ttt.awk: reads a 9-char board (X O .) per line, prints best move 0-8.
# Side to move is X when counts are equal, else O. Terminal/bad input: ?
BEGIN {
  split("123 456 789 147 258 369 159 357", W, " ")
}
function won(b, p,   k, t) {
  for (k = 1; k <= 8; k++) {
    t = W[k]
    if (substr(b,substr(t,1,1),1) == p && substr(b,substr(t,2,1),1) == p && substr(b,substr(t,3,1),1) == p) return 1
  }
  return 0
}
function val(b, p, q,   i, v, best) {
  if (won(b, q)) return -1
  best = -2
  for (i = 1; i <= 9; i++)
    if (substr(b,i,1) == ".") {
      v = -val(substr(b,1,i-1) p substr(b,i+1), q, p)
      if (v > best) best = v
    }
  return best == -2 ? 0 : best
}
{
  b = $0
  if (b !~ /^[XO.]{9}$/) { print "?"; next }
  x = gsub(/X/, "X", b); o = gsub(/O/, "O", b)
  if (x < o || x > o + 1 || won(b,"X") || won(b,"O")) { print "?"; next }
  p = (x == o) ? "X" : "O"; q = (p == "X") ? "O" : "X"
  best = -2; mv = -1
  for (i = 1; i <= 9; i++)
    if (substr(b,i,1) == ".") {
      v = -val(substr(b,1,i-1) p substr(b,i+1), q, p)
      if (v > best) { best = v; mv = i - 1 }
    }
  print (mv < 0 ? "?" : mv)
}
