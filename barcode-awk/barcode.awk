#!/usr/bin/awk -f
# barcode-awk: text in, Code 128 (code set B) barcode out, as a plain PBM (P1).
# usage: echo 'goblincouncil' | awk -f barcode.awk > out.pbm
#   -v scale=N  module width in pixels (default 2)
#   -v h=N      bar height in pixels (default 60)
# one line of input = one barcode. Printable ASCII 32..126 only.
BEGIN {
  # widths of bar, space, bar, space, bar, space for symbol values 0..106
  n = split("212222 222122 222221 121223 121322 131222 122213 122312 132212 221213 221312 231212 112232 122132 122231 113222 123122 123221 223211 221132 221231 213212 223112 312131 311222 321122 321221 312212 322112 322211 212123 212321 232121 111323 131123 131321 112313 132113 132311 211313 231113 231311 112133 112331 132131 113123 113321 133121 313121 211331 231131 213113 213311 213131 311123 311321 331121 312113 312311 332111 314111 221411 431111 111224 111422 121124 121421 141122 141221 112214 112412 122114 122411 142112 142211 241211 221114 413111 241112 134111 111242 121142 121241 114212 124112 124211 411212 421112 421211 212141 214121 412121 111143 111341 131141 114113 114311 411113 411311 113141 114131 311141 411131 211412 211214 211232 2331112", W, " ")
  for (i = 32; i < 127; i++) ORD[sprintf("%c", i)] = i
  if (scale == "") scale = 2
  if (h == "") h = 60
}
NR > 1 { exit }
{
  line = $0
  if (line == "") { print "barcode-awk: empty input" > "/dev/stderr"; bad = 1; exit }
  for (i = 1; i <= length(line); i++) {
    c = substr(line, i, 1)
    if (!(c in ORD)) { print "barcode-awk: only printable ASCII" > "/dev/stderr"; bad = 1; exit }
  }
  # values: Start B (104), each char minus 32, checksum, Stop (106)
  sum = 104; v[1] = 104; k = 1
  for (i = 1; i <= length(line); i++) {
    k++; v[k] = ORD[substr(line, i, 1)] - 32
    sum += v[k] * (i)
  }
  k++; v[k] = sum % 103
  k++; v[k] = 106
  # build one row of modules: quiet zone of 10, then alternating bar/space
  row = "0000000000"
  for (j = 1; j <= k; j++) {
    p = W[v[j] + 1]
    for (m = 1; m <= length(p); m++) {
      bit = (m % 2) ? "1" : "0"
      for (r = 0; r < substr(p, m, 1); r++) row = row bit
    }
  }
  row = row "0000000000"
  # PBM: 1 is black. widen each module by scale, add 10 blank rows top and bottom
  wpx = length(row) * scale
  ht = h + 20
  print "P1"
  print "# barcode-awk: " line
  print wpx, ht
  out = ""
  for (m = 1; m <= length(row); m++)
    for (s = 0; s < scale; s++) out = out substr(row, m, 1)
  blank = out; gsub(/1/, "0", blank)
  for (y = 0; y < ht; y++) printrow((y < 10 || y >= h + 10) ? blank : out)
}
function printrow(r,   o, i) {
  # PBM lines should stay under 70 chars
  for (i = 1; i <= length(r); i += 64) print substr(r, i, 64)
}
# a bare exit in a rule still runs END, so the exit status is decided here
END {
  if (NR == 0) print "barcode-awk: no input" > "/dev/stderr"
  if (NR == 0 || bad) exit 1
}
