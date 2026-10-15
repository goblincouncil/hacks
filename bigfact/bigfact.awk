# usage: awk -f bigfact.awk   (reads one integer n per line, prints n!)
# the number is an array of base-10000 limbs, least significant first
function fact(n,   d, i, k, c, v, s) {
  d[0] = 1; k = 1
  for (i = 2; i <= n; i++) {
    c = 0
    for (v = 0; v < k; v++) { c += d[v] * i; d[v] = c % 10000; c = int(c / 10000) }
    while (c > 0) { d[k++] = c % 10000; c = int(c / 10000) }
  }
  s = d[k-1]
  for (v = k - 2; v >= 0; v--) s = s sprintf("%04d", d[v])
  return s
}
/^[0-9]+$/ { print fact($1); next }
{ print "?" }
