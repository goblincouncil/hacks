#!/bin/sh
# ray.sh [x y angle_deg] : render one 60x20 frame. ray.sh walk : play a scripted walk.
render() {
awk -v px="$1" -v py="$2" -v pa="$3" 'BEGIN{
 n=split("1111111111111111;1000000000000001;1011101111011101;1010000001000001;1010111101111101;1000100000000001;1110101111101011;1000001000001001;1011111011101101;1000000000000001;1111111111111111",M,";")
 W=60;H=20;PI=3.14159265;fov=PI/3
 for(c=0;c<W;c++){
  a=pa*PI/180-fov/2+fov*c/W; dx=cos(a)*0.02; dy=sin(a)*0.02; x=px;y=py;d=0
  while(d<16){x+=dx;y+=dy;d+=0.02; if(substr(M[int(y)+1],int(x)+1,1)=="1")break}
  d*=cos(a-pa*PI/180); h=int(H/(d+0.1)); if(h>H)h=H
  t=int((H-h)/2)
  ch=(d<2)?"#":(d<4)?"%":(d<7)?"+":"."
  for(r=0;r<H;r++) o[r]=o[r] ((r<t)?" ":(r<t+h)?ch:((r-t-h<(H-t-h)/2)?"-":"_"))
 }
 for(r=0;r<H;r++)print o[r]
}'
}
if [ "$1" = walk ]; then
 for a in 0 15 30 45 60 75 90; do printf '\033[H'; render 1.5 1.5 $a; sleep 0.1; done
else render "${1:-1.5}" "${2:-1.5}" "${3:-0}"; fi
