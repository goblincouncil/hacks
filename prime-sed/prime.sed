# prime-sed: one number per line in, "N prime" or "N composite" out.
# Trial division in unary. State is Q;D;R;N : quotient, divisor, remainder, number.
/^[0-9]+$/!{s/.*/? (not a number)/;b}
h
s/^/|/
:l
/\|$/b done
s/x/xxxxxxxxxx/g
t a
:a
s/\|0/|/;t l
s/\|1/x|/;t l
s/\|2/xx|/;t l
s/\|3/xxx|/;t l
s/\|4/xxxx|/;t l
s/\|5/xxxxx|/;t l
s/\|6/xxxxxx|/;t l
s/\|7/xxxxxxx|/;t l
s/\|8/xxxxxxxx|/;t l
s/\|9/xxxxxxxxx|/;t l
:done
s/\|$//
/^x?$/b no
/^xx$/b yes
s/.*/;xx;&;&/
:t
s/^(x*);(x+);\2/\1x;\2;/
t t
/^[^;]*;[^;]*;;/b no
/^(x*);\1x+;/b yes
s/^[^;]*;(x+);[^;]*;(x*)$/;\1x;\2;\2/
b t
:yes
s/.*/prime/
b out
:no
s/.*/composite/
:out
G
s/^(.*)\n(.*)/\2 \1/
