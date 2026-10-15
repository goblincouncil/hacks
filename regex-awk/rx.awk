# tiny regex grep: literals . * ^ $ (Kernighan and Pike). usage: awk -v re=PATTERN -f rx.awk file
function mhere(r, t,   c) {
  if (r == "") return 1
  c = substr(r, 1, 1)
  if (substr(r, 2, 1) == "*") return mstar(c, substr(r, 3), t)
  if (c == "$" && length(r) == 1) return t == ""
  if (t != "" && (c == "." || c == substr(t, 1, 1))) return mhere(substr(r, 2), substr(t, 2))
  return 0
}
function mstar(c, r, t) {
  while (1) {
    if (mhere(r, t)) return 1
    if (t == "" || (c != "." && substr(t, 1, 1) != c)) return 0
    t = substr(t, 2)
  }
}
function rmatch(r, t,   i) {
  if (substr(r, 1, 1) == "^") return mhere(substr(r, 2), t)
  for (i = 1; i <= length(t) + 1; i++) if (mhere(r, substr(t, i))) return 1
  return 0
}
rmatch(re, $0)
