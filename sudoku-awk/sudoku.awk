# usage: awk -f sudoku.awk puzzles.txt  (one 81-char line per puzzle, 0 or . = blank)
function ok(p,v,  r,c,i,br,bc){
  r=int(p/9); c=p%9
  for(i=0;i<9;i++){ if(g[r*9+i]==v||g[i*9+c]==v) return 0 }
  br=int(r/3)*3; bc=int(c/3)*3
  for(i=0;i<9;i++) if(g[(br+int(i/3))*9+bc+i%3]==v) return 0
  return 1
}
function solve(p,  v){
  while(p<81 && g[p]!=0) p++
  if(p==81) return 1
  for(v=1;v<=9;v++) if(ok(p,v)){ g[p]=v; if(solve(p+1)) return 1; g[p]=0 }
  return 0
}
function valid(  p,v){
  for(p=0;p<81;p++) if(g[p]!=0){ v=g[p]; g[p]=0; if(!ok(p,v)){g[p]=v; return 0}; g[p]=v }
  return 1
}
{
  gsub(/\./,"0"); if(length($0)!=81 || $0!~/^[0-9]+$/){ print "bad"; next }
  for(i=0;i<81;i++) g[i]=substr($0,i+1,1)+0
  if(valid() && solve(0)){ s=""; for(i=0;i<81;i++) s=s g[i]; print s } else print "none"
}
