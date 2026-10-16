# huff.awk: Huffman coding. encode: gawk -f huff.awk < file   (via od)
# decode: gawk -v d=1 -f huff.awk < encoded
# encoded format: "N" line (symbol count), "sym code" lines, then bit string line
function mk(  i,a,b,m,k,n){
  n=0; for(k in f){ n++; w[k]=f[k]; mn[k]=k+0; live[k]=1 }
  nid=256
  while(n>1){
    a=-1;b=-1
    for(k in live){
      if(a<0||w[k]<w[a]||(w[k]==w[a]&&mn[k]<mn[a])) a=k
    }
    delete live[a]
    for(k in live){
      if(b<0||w[k]<w[b]||(w[k]==w[b]&&mn[k]<mn[b])) b=k
    }
    delete live[b]
    w[nid]=w[a]+w[b]; mn[nid]=(mn[a]<mn[b]?mn[a]:mn[b]); L[nid]=a; R[nid]=b; live[nid]=1; nid++; n--
  }
  for(k in live) root=k
}
function walk(x,c){
  if(x in L){ walk(L[x],c "0"); walk(R[x],c "1") }
  else code[x]=(c==""?"0":c)
}
BEGIN{ d=d+0 }
d==0{ for(i=1;i<=NF;i++){ s[++ns]=$i+0; f[$i+0]++ } }
d==1{ if(NR==1) nsym=$1; else if(NR<=nsym+1) dec[$2]=$1; else bits=$1 }
END{
  if(d==0){
    if(ns==0){ print 0; print ""; exit }
    mk(); walk(root,"")
    print length(f)
    for(k in code) print k, code[k]
    o=""; for(i=1;i<=ns;i++) o=o code[s[i]]
    print o
  } else {
    if(nsym==0) exit
    cur=""; for(i=1;i<=length(bits);i++){
      cur=cur substr(bits,i,1)
      if(cur in dec){ printf "%c", dec[cur]+0; cur="" }
    }
    if(cur!=""){ print "?" > "/dev/stderr"; exit 1 }
  }
}
