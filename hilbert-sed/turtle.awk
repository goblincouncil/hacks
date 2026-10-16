# turtle.awk: walk Hilbert turtle commands and draw them as an SVG.
# Input: one line of F + - (from hilbert.sed).
# F = step forward one cell, + = turn left, - = turn right.
# With -v points=1 it prints one "x y" grid point per line instead of SVG.
BEGIN { cell = 8; pad = 4 }
{
  x = 0; y = 0; dx = 1; dy = 0; n = 0
  px[n] = x; py[n] = y; n++
  len = length($0)
  for (i = 1; i <= len; i++) {
    c = substr($0, i, 1)
    if (c == "F") { x += dx; y += dy; px[n] = x; py[n] = y; n++ }
    else if (c == "+") { t = dx; dx = -dy; dy = t }
    else if (c == "-") { t = dx; dx = dy; dy = -t }
    else { print "turtle.awk: bad command " c > "/dev/stderr"; bad = 1; exit 2 }
  }
}
END {
  if (bad) exit 2
  if (n == 0) { print "turtle.awk: no input" > "/dev/stderr"; exit 2 }
  # shift so the smallest coordinate is 0; y grows downward in SVG
  minx = maxx = px[0]; miny = maxy = py[0]
  for (k = 1; k < n; k++) {
    if (px[k] < minx) minx = px[k]; if (px[k] > maxx) maxx = px[k]
    if (py[k] < miny) miny = py[k]; if (py[k] > maxy) maxy = py[k]
  }
  if (points) {
    for (k = 0; k < n; k++) print px[k] - minx, maxy - py[k]
    exit 0
  }
  w = (maxx - minx) * cell + 2 * pad; h = (maxy - miny) * cell + 2 * pad
  printf "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\">\n", w, h
  printf "<rect width=\"100%%\" height=\"100%%\" fill=\"#111\"/>\n"
  printf "<polyline fill=\"none\" stroke=\"#7fdc5a\" stroke-width=\"2\" points=\""
  for (k = 0; k < n; k++)
    printf "%s%d,%d", (k ? " " : ""), (px[k] - minx) * cell + pad, (maxy - py[k]) * cell + pad
  printf "\"/>\n</svg>\n"
}
