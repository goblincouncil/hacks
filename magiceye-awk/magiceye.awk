#!/usr/bin/awk -f
# magiceye.awk: a digit depth map in, a text autostereogram out.
# usage: awk -v P=16 -v seed=1 -f magiceye.awk map.txt
# map: rows of 0-9 (dot or space means 0). P: pattern period, 10..99.
function die(msg) { print "magiceye: " msg > "/dev/stderr"; bad = 1; exit 1 }
function rnd() { s = (s * 16807) % 2147483647; return s }
BEGIN {
  if (P == "") P = 16
  if (seed == "") seed = 1
  if (P !~ /^[0-9]+$/ || P + 0 < 10 || P + 0 > 99) die("P must be an integer from 10 to 99")
  if (seed !~ /^[0-9]+$/ || seed + 0 < 1 || seed + 0 > 2147483646) die("seed must be an integer from 1 to 2147483646")
  P += 0; s = seed + 0
  abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
}
{
  line = $0; sub(/\r$/, "", line)
  if (line ~ /[^0-9. ]/) die("line " NR ": only digits, dots and spaces allowed")
  row[NR] = line
  if (length(line) > W) W = length(line)
}
END {
  if (bad) exit 1
  if (NR == 0) die("empty depth map")
  for (r = 1; r <= NR; r++) {
    out = ""
    for (x = 1; x <= P + W; x++) {
      if (x <= P) c[x] = substr(abc, rnd() % 52 + 1, 1)
      else {
        d = substr(row[r], x - P, 1)
        d = (d ~ /[0-9]/) ? d + 0 : 0
        c[x] = c[x - P + d]   # nearer means a shorter repeat
      }
      out = out c[x]
    }
    print out
  }
}
