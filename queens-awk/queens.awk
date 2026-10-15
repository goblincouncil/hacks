# queens.awk: N-queens. usage: awk -v n=8 -f queens.awk
# prints first solution as a board, then "n=8 solutions=92"
function place(r,   c) {
  if (r > n) { if (!cnt++) for (i = 1; i <= n; i++) { s = ""; for (j = 1; j <= n; j++) s = s (col[i] == j ? "Q " : ". "); print s } ; return }
  for (c = 1; c <= n; c++)
    if (!(c in C) && !((r+c) in D) && !((r-c) in E)) {
      C[c]; D[r+c]; E[r-c]; col[r] = c
      place(r+1)
      delete C[c]; delete D[r+c]; delete E[r-c]
    }
}
BEGIN {
  if (n !~ /^[0-9]+$/ || n < 1) { print "usage: awk -v n=N -f queens.awk" > "/dev/stderr"; exit 2 }
  place(1); print "n=" n " solutions=" cnt + 0
}
