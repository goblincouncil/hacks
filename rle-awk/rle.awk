# usage: awk -v mode=enc|dec -f rle.awk   (per line; decode expects count+char pairs)
{
  out=""
  if (mode=="dec") {
    s=$0
    while (match(s,/^[0-9]+./)) { n=substr(s,1,RLENGTH-1)+0; c=substr(s,RLENGTH,1); for(i=0;i<n;i++) out=out c; s=substr(s,RLENGTH+1) }
  } else {
    n=length($0); i=1
    while (i<=n) { c=substr($0,i,1); j=i; while (j<=n && substr($0,j,1)==c) j++; out=out (j-i) c; i=j }
  }
  print out
}
