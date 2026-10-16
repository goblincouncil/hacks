# LZW in awk. encode: gawk -f lzw.awk ; decode: gawk -v d=1 -f lzw.awk
# run with LC_ALL=C. Input must not contain NUL. Encoder ends input with a newline.
BEGIN { for (i = 1; i < 256; i++) T[sprintf("%c", i)] = i; n = 256; w = ""
        for (i = 1; i < 256; i++) D[i] = sprintf("%c", i) }
!d { s = $0 "\n"
     for (i = 1; i <= length(s); i++) { c = substr(s, i, 1)
       if ((w c) in T) w = w c
       else { o = o T[w] " "; T[w c] = n++; w = c } } }
d { for (j = 1; j <= NF; j++) { k = $j
      if (k !~ /^[0-9]+$/) { bad = 1; next }
      k += 0
      if (k in D) e = D[k]
      else if (k == n && w != "") e = w substr(w, 1, 1)
      else { bad = 1; next }
      o = o e
      if (w != "") D[n++] = w substr(e, 1, 1)
      w = e } }
END { if (bad) { print "?"; exit 1 }
      if (d) printf "%s", o
      else { if (w != "") o = o T[w]; print o } }
