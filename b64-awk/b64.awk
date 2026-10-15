# base64 enc/dec in gawk, arithmetic only. LC_ALL=C gawk -v mode=enc|dec -f b64.awk FILE
BEGIN { RS = "^$"; A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  for (i = 0; i < 256; i++) ord[sprintf("%c", i)] = i
  for (i = 0; i < 64; i++) val[substr(A, i + 1, 1)] = i }
{ s = $0; n = length(s); out = ""
  if (mode == "enc") {
    for (i = 1; i <= n; i += 3) {
      r = n - i + 1; if (r > 3) r = 3
      a = ord[substr(s, i, 1)]; b = (r > 1) ? ord[substr(s, i + 1, 1)] : 0; c = (r > 2) ? ord[substr(s, i + 2, 1)] : 0
      v = a * 65536 + b * 256 + c
      o = substr(A, int(v / 262144) % 64 + 1, 1) substr(A, int(v / 4096) % 64 + 1, 1)
      o = o ((r > 1) ? substr(A, int(v / 64) % 64 + 1, 1) : "=") ((r > 2) ? substr(A, v % 64 + 1, 1) : "=")
      out = out o
    }
    print out
  } else {
    q = 0; v = 0
    for (i = 1; i <= n; i++) {
      ch = substr(s, i, 1); if (!(ch in val)) continue
      v = v * 64 + val[ch]; q++
      if (q == 4) { out = out sprintf("%c%c%c", int(v / 65536), int(v / 256) % 256, v % 256); q = 0; v = 0 }
    }
    if (q == 2) out = out sprintf("%c", int(v / 16))
    else if (q == 3) out = out sprintf("%c%c", int(v / 1024), int(v / 4) % 256)
    printf "%s", out
  }
}
