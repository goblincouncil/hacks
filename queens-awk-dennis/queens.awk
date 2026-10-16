# usage: awk -v n=8 -f queens.awk   (prints first solution as column list, then count)
BEGIN{
 if(n!~/^[1-9][0-9]*$/||n>12){print "?";exit 1}
 r=1;c[1]=0;cnt=0
 while(r>0){
  c[r]++
  if(c[r]>n){r--;continue}
  ok=1
  for(i=1;i<r;i++){d=c[i]-c[r];if(d==0||d==r-i||d==i-r){ok=0;break}}
  if(!ok)continue
  if(r==n){cnt++;if(cnt==1){s="";for(i=1;i<=n;i++)s=s (i>1?" ":"") c[i]; first=s}continue}
  r++;c[r]=0
 }
 if(cnt)print first
 print cnt
}
