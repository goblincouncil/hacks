# tartan.awk - weave a tartan threadcount into a 2/2 twill PPM (P3).
# usage: awk -v sett='K4 R24 K24 Y4' [-v size=N] -f tartan.awk
# The sett is symmetric: it is woven forward, then mirrored back,
# with the two end stripes acting as pivots (counted once each).
BEGIN {
  col["K"] = "16 16 16";   col["W"] = "240 240 232"
  col["R"] = "190 20 30";  col["G"] = "20 100 40"
  col["B"] = "20 40 140";  col["Y"] = "230 190 20"
  col["N"] = "20 25 60";   col["P"] = "110 40 120"
  col["O"] = "220 110 20"; col["A"] = "140 140 150"
  if (size == "") size = 240
  if (size !~ /^[0-9]+$/ || size + 0 < 1 || size + 0 > 4000) die("bad size")
  n = split(sett, t, /[ \t]+/)
  m = 0
  for (i = 1; i <= n; i++) {
    if (t[i] == "") continue
    if (t[i] !~ /^[A-Z][0-9]+$/) die("bad stripe " t[i])
    c = substr(t[i], 1, 1); w = substr(t[i], 2) + 0
    if (!(c in col)) die("unknown colour " c)
    if (w < 1) die("empty stripe " t[i])
    m++; sc[m] = c; sw[m] = w
  }
  if (m < 1) die("empty sett")
  L = 0
  for (i = 1; i <= m; i++) for (j = 0; j < sw[i]; j++) th[L++] = sc[i]
  for (i = m - 1; i >= 2; i--) for (j = 0; j < sw[i]; j++) th[L++] = sc[i]
  print "P3"; print size, size; print 255
  for (y = 0; y < size; y++) {
    line = ""
    for (x = 0; x < size; x++) {
      # 2/2 twill: warp floats where (x + y) % 4 < 2, weft elsewhere
      p = ((x + y) % 4 < 2) ? th[x % L] : th[y % L]
      line = line (x ? " " : "") col[p]
    }
    print line
  }
  exit 0
}
function die(msg) { print "tartan: " msg > "/dev/stderr"; exit 1 }
