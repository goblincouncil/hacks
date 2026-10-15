# gcd of "a b": decimal -> unary, Euclid by backreference regex, unary -> decimal
/^[0-9]+ [0-9]+$/!{s/.*/?/;b}
s/^/;/
:d
s/^(x*);([0-9])/\1\1\1\1\1\1\1\1\1\1<\2>;/
s/<0>//
s/<1>/x/
s/<2>/xx/
s/<3>/xxx/
s/<4>/xxxx/
s/<5>/xxxxx/
s/<6>/xxxxxx/
s/<7>/xxxxxxx/
s/<8>/xxxxxxxx/
s/<9>/xxxxxxxxx/
t d
s/^(x*); ([0-9]+)$/;\2 \1/
t d
s/;//
:e
/^(x*) \1$/{s/ .*//;b o
}
/^ (x+)$/{s/^ //;b o
}
/^(x+) $/{s/ $//;b o
}
s/^(x+)(x+) \1$/\2 \1/
t e
s/^(x+) \1(x+)$/\1 \2/
t e
:o
/^$/{s/.*/0/;b
}
s/$/;/
:n
/^x/!b f
s/^x//
s/;([0-9]*)$/;\1@/
:z
s/9@/@0/
t z
s/;@/;1/
t n
s/0@/1/;t n
s/1@/2/;t n
s/2@/3/;t n
s/3@/4/;t n
s/4@/5/;t n
s/5@/6/;t n
s/6@/7/;t n
s/7@/8/;t n
s/8@/9/;t n
:f
s/^;//
