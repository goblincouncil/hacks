# usage: echo N | awk -f collatz.awk   prints "N steps peak"
/^[0-9]+$/ && $1 > 0 {
  n = $1; s = 0; p = n
  while (n != 1) { n = (n % 2) ? 3 * n + 1 : n / 2; s++; if (n > p) p = n }
  print $1, s, p; next
}
{ print "?"; bad = 1 }
END { exit bad }
