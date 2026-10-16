# usage: awk -f tm.awk table  (lines: STATE READ WRITE L|R NEXT; start = first state; halt = H)
NF==5 && $1!~/^#/ { if(!s0) s0=$1; w[$1,$2]=$3; d[$1,$2]=$4; n[$1,$2]=$5; next }
NF && $1!~/^#/ { print "?"; bad=1; exit 1 }
END {
  if (bad) exit 1
  s=s0; p=0; st=0; max=10000000
  while (s!="H") {
    r=((p in t)?t[p]:0)
    if (!((s,r) in n)) { print "?"; exit 1 }
    t[p]=w[s,r]; p+=(d[s,r]=="R")?1:-1; s=n[s,r]
    if (++st>max) { print "?"; exit 1 }
  }
  c=0; for (k in t) if (t[k]==1) c++
  print "steps " st " ones " c
}
