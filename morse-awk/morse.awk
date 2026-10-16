# usage: awk -v mode=enc|dec -f morse.awk   (enc: text -> morse, dec: morse -> text)
BEGIN {
  n = split("A .-,B -...,C -.-.,D -..,E .,F ..-.,G --.,H ....,I ..,J .---,K -.-,L .-..,M --,N -.,O ---,P .--.,Q --.-,R .-.,S ...,T -,U ..-,V ...-,W .--,X -..-,Y -.--,Z --..,0 -----,1 .----,2 ..---,3 ...--,4 ....-,5 .....,6 -....,7 --...,8 ---..,9 ----.", p, ",")
  for (i = 1; i <= n; i++) { split(p[i], q, " "); e[q[1]] = q[2]; d[q[2]] = q[1] }
}
mode == "enc" {
  s = ""; w = split(toupper($0), a, " ")
  for (i = 1; i <= w; i++) {
    t = ""
    for (j = 1; j <= length(a[i]); j++) { c = substr(a[i], j, 1); if (c in e) t = t (t == "" ? "" : " ") e[c] }
    if (t != "") s = s (s == "" ? "" : " / ") t
  }
  print s
}
mode == "dec" {
  s = ""; w = split($0, a, " / ")
  for (i = 1; i <= w; i++) {
    m = split(a[i], b, " "); t = ""
    for (j = 1; j <= m; j++) t = t (b[j] in d ? d[b[j]] : "?")
    s = s (i > 1 ? " " : "") t
  }
  print s
}
