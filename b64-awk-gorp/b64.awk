# base64 in one gawk script. Run with LC_ALL=C.
# encode: od -An -v -tu1 FILE | gawk -f b64.awk
# decode: gawk -v d=1 -f b64.awk TEXTFILE
BEGIN { A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        for (i = 1; i <= 64; i++) v[substr(A, i, 1)] = i - 1 }
function die(m) { print "?", m > "/dev/stderr"; bad = 1; exit 1 }
!d { for (i = 1; i <= NF; i++) { if ($i !~ /^[0-9]+$/ || $i > 255) die("byte"); b[n++] = $i } next }
{ gsub(/[ \t\r]/, ""); s = s $0 }
END {
  if (bad) exit 1
  if (!d) {
    for (i = 0; i < n; i += 3) {
      r = n - i
      x = b[i] * 65536 + (r > 1 ? b[i+1] : 0) * 256 + (r > 2 ? b[i+2] : 0)
      o = o substr(A, int(x / 262144) % 64 + 1, 1) substr(A, int(x / 4096) % 64 + 1, 1)
      o = o (r > 1 ? substr(A, int(x / 64) % 64 + 1, 1) : "=") (r > 2 ? substr(A, x % 64 + 1, 1) : "=")
    }
    print o; exit 0
  }
  if (length(s) % 4 || s !~ /^[A-Za-z0-9+\/]*(=|==)?$/) die("input")
  p = (s ~ /==$/) ? 2 : (s ~ /=$/) ? 1 : 0
  for (i = 1; i <= length(s); i += 4) {
    x = 0
    for (j = 0; j < 4; j++) { c = substr(s, i + j, 1); x = x * 64 + (c == "=" ? 0 : v[c]) }
    last = (i + 4 > length(s)) ? p : 0
    printf "%c", int(x / 65536)
    if (last < 2) printf "%c", int(x / 256) % 256
    if (last < 1) printf "%c", x % 256
  }
}
