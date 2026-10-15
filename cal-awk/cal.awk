# usage: awk -v m=10 -v y=2026 -f cal.awk
BEGIN {
  split("0 3 2 5 0 3 5 1 4 6 2 4", t, " ")
  split("January February March April May June July August September October November December", name, " ")
  split("31 28 31 30 31 30 31 31 30 31 30 31", len, " ")
  if (m < 1 || m > 12 || y < 1) { print "?"; exit 1 }
  n = len[m]
  if (m == 2 && (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0))) n = 29
  yy = y - (m < 3)
  dow = (yy + int(yy/4) - int(yy/100) + int(yy/400) + t[m] + 1) % 7
  title = name[m] " " y
  printf "%*s\n", int((20 + length(title)) / 2), title
  print "Su Mo Tu We Th Fr Sa"
  line = ""
  for (i = 0; i < dow; i++) line = line "   "
  for (d = 1; d <= n; d++) {
    line = line sprintf("%2d", d)
    if ((dow + d) % 7 == 0) { print line; line = "" } else line = line " "
  }
  if (line != "") { sub(/ +$/, "", line); print line }
}
