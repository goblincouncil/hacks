# sudoku.awk: reads 81-char lines (digits, 0 or . = blank), prints solution or ?
function ok(p, v,   r, c, i, br, bc) {
  r = int(p / 9); c = p % 9
  for (i = 0; i < 9; i++) {
    if (g[r * 9 + i] == v || g[i * 9 + c] == v) return 0
  }
  br = r - r % 3; bc = c - c % 3
  for (i = 0; i < 9; i++)
    if (g[(br + int(i / 3)) * 9 + bc + i % 3] == v) return 0
  return 1
}
function solve(p,   v) {
  while (p < 81 && g[p] != 0) p++
  if (p == 81) return 1
  for (v = 1; v <= 9; v++)
    if (ok(p, v)) { g[p] = v; if (solve(p + 1)) return 1; g[p] = 0 }
  return 0
}
function valid(   p, v) {
  for (p = 0; p < 81; p++) if (g[p]) { v = g[p]; g[p] = 0; if (!ok(p, v)) return 0; g[p] = v }
  return 1
}
{
  if ($0 !~ /^[0-9.]+$/ || length($0) != 81) { print "?"; next }
  for (i = 0; i < 81; i++) { c = substr($0, i + 1, 1); g[i] = (c == ".") ? 0 : c + 0 }
  if (!valid() || !solve(0)) { print "?"; next }
  s = ""; for (i = 0; i < 81; i++) s = s g[i]
  print s
}
