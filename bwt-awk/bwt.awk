# bwt.awk: Burrows-Wheeler transform. gawk -v mode=enc|dec, one line per record.
# A hidden end marker (shown as $) is added; input may not contain $.
BEGIN { if (mode != "enc" && mode != "dec") { print "?"; bad = 1; exit 1 } }
{
  s = $0; n = length(s)
  if (mode == "enc") {
    if (index(s, "$")) { print "?"; bad = 1; exit 1 }
    t = s "\001"; m = length(t)
    delete r
    for (i = 0; i < m; i++) r[i + 1] = substr(t, i + 2) substr(t, 1, i + 1)
    asort(r)
    o = ""
    for (i = 1; i <= m; i++) o = o substr(r[i], m, 1)
    gsub(/\001/, "$", o); print o
  } else {
    if (n < 1 || gsub(/\$/, "&", s) != 1) { print "?"; bad = 1; exit 1 }
    delete k
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1); if (c == "$") c = "\001"
      L[i] = c; k[i] = c sprintf("%08d", i)
    }
    asort(k)
    for (j = 1; j <= n; j++) { p[j] = substr(k[j], length(k[j]) - 7) + 0; F[j] = substr(k[j], 1, length(k[j]) - 8) }
    j = 1; o = ""
    for (i = 1; i < n; i++) { j = p[j]; o = o F[j] }
    print o
  }
}
END { if (bad) exit 1 }
