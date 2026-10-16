# luhn.awk: line "N" -> "N ok|bad"; line "gen N" -> N plus its check digit
function sum(s,   i,d,t,alt) {
  alt = 1
  for (i = length(s); i >= 1; i--) {
    d = substr(s, i, 1) + 0
    if (alt = !alt) { d *= 2; if (d > 9) d -= 9 }
    t += d
  }
  return t % 10
}
/^gen [0-9]+$/ { c = (10 - sum($2 "0")) % 10; print $2 c; next }
/^[0-9]+$/ { print $1, (sum($1) == 0 ? "ok" : "bad"); next }
{ print $0, "?" }
