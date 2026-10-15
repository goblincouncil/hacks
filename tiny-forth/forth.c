/* forth.c - a small Forth. reads a program on stdin. cc -o forth forth.c */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define P "+ - * / mod dup drop swap over rot . emit cr = < > and or negate"
static int code[9999], here, ds[256], sp, rs[256], rp, nw, np, addr[999], cs[64], cp;
static char nm[999][32], *src, *tok;
static int find(const char *s){ for(int i=nw-1;i>=0;i--) if(!strcmp(nm[i],s)) return i; return -1; }
static void prim(int o){ int a,b;
 switch(o){
 case 0:ds[sp-2]+=ds[sp-1];sp--;break; case 1:ds[sp-2]-=ds[sp-1];sp--;break;
 case 2:ds[sp-2]*=ds[sp-1];sp--;break; case 3:ds[sp-2]/=ds[sp-1];sp--;break;
 case 4:ds[sp-2]%=ds[sp-1];sp--;break; case 5:ds[sp]=ds[sp-1];sp++;break;
 case 6:sp--;break; case 7:a=ds[sp-1];ds[sp-1]=ds[sp-2];ds[sp-2]=a;break;
 case 8:ds[sp]=ds[sp-2];sp++;break;
 case 9:a=ds[sp-3];ds[sp-3]=ds[sp-2];ds[sp-2]=ds[sp-1];ds[sp-1]=a;break;
 case 10:printf("%d ",ds[--sp]);break; case 11:putchar(ds[--sp]);break;
 case 12:putchar('\n');break;
 case 13:ds[sp-2]=-(ds[sp-2]==ds[sp-1]);sp--;break;
 case 14:ds[sp-2]=-(ds[sp-2]<ds[sp-1]);sp--;break;
 case 15:ds[sp-2]=-(ds[sp-2]>ds[sp-1]);sp--;break;
 case 16:ds[sp-2]&=ds[sp-1];sp--;break; case 17:ds[sp-2]|=ds[sp-1];sp--;break;
 case 18:ds[sp-1]=-ds[sp-1];break; } }
static void run(int ip){ for(;;){ int c=code[ip++];
 if(c>=0){ if(addr[c]<0) prim(-addr[c]-1); else run(addr[c]); }
 else switch(c){
 case -1:ds[sp++]=code[ip++];break; case -2:ip=code[ip];break;
 case -3:ip=ds[--sp]?ip+1:code[ip];break; case -4:return;
 case -5:rs[rp]=ds[sp-2];rs[rp+1]=ds[sp-1];rp+=2;sp-=2;break;
 case -6:if(++rs[rp-1]<rs[rp-2]) ip=code[ip]; else {rp-=2;ip++;} break;
 case -7:ds[sp++]=rs[rp-1];break; } } }
static int next(void){ while(*src==' '||*src=='\n'||*src=='\t') src++;
 if(!*src) return 0; tok=src; while(*src&&*src!=' '&&*src!='\n'&&*src!='\t') src++;
 if(*src) *src++=0; return 1; }
static void emit(int c){ code[here++]=c; }
int main(void){ static char buf[1<<16]; int n=fread(buf,1,sizeof buf-1,stdin), comp=0; buf[n]=0; src=buf;
 char *p=strdup(P), *t; for(t=strtok(p," ");t;t=strtok(0," ")){ strcpy(nm[nw],t); addr[nw]=-(++np); nw++; }
 while(next()){
  if(!strcmp(tok,"(")){ while(next()&&strcmp(tok,")")); continue; }
  if(!strcmp(tok,"\\")){ while(*src&&*src!='\n') src++; continue; }
  if(!strcmp(tok,":")){ next(); strcpy(nm[nw],tok); addr[nw++]=here; comp=1; continue; }
  if(!strcmp(tok,";")){ emit(-4); comp=0; continue; }
  if(comp){
   if(!strcmp(tok,"if")){ emit(-3); cs[cp++]=here; emit(0); }
   else if(!strcmp(tok,"else")){ emit(-2); code[cs[--cp]]=here+1; cs[cp++]=here; emit(0); }
   else if(!strcmp(tok,"then")) code[cs[--cp]]=here;
   else if(!strcmp(tok,"begin")) cs[cp++]=here;
   else if(!strcmp(tok,"until")){ emit(-3); emit(cs[--cp]); }
   else if(!strcmp(tok,"do")){ emit(-5); cs[cp++]=here; }
   else if(!strcmp(tok,"loop")){ emit(-6); emit(cs[--cp]); }
   else if(!strcmp(tok,"i")) emit(-7);
   else if(!strcmp(tok,".\"")){ while(*src!='"'){ emit(-1); emit(*src++); emit(find("emit")); } src++; }
   else if(find(tok)>=0) emit(find(tok));
   else { emit(-1); emit(atoi(tok)); }
  } else {
   if(!strcmp(tok,".\"")){ while(*src!='"') putchar(*src++); src++; }
   else if(find(tok)>=0){ int w=find(tok); if(addr[w]<0) prim(-addr[w]-1); else run(addr[w]); }
   else ds[sp++]=atoi(tok);
  } }
 return 0; }
