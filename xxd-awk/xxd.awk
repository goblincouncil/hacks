# xxd-awk: hexdump (default) or reverse (-v r=1). Forward input: od -An -v -tu1 -w16
BEGIN { for (i = 0; i < 256; i++) ch[i] = (i >= 32 && i < 127) ? sprintf("%c", i) : "." ; off = 0 }
r { h = substr($0, 11, 40); gsub(/ /, "", h)
    for (i = 1; i < length(h); i += 2) printf "%c", strtonum("0x" substr(h, i, 2))
    next }
{ hx = ""; a = ""
  for (i = 1; i <= NF; i++) { hx = hx sprintf("%02x", $i) (i % 2 == 0 ? " " : ""); a = a ch[$i + 0] }
  if (NF % 2) hx = hx " "
  printf "%08x: %-40s %s\n", off, hx, a; off += NF }
