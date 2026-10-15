: sq dup * ;
: fizz 16 1 do i 15 mod 0 = if ." FizzBuzz" else i 5 mod 0 = if ." Buzz" else i 3 mod 0 = if ." Fizz" else i . then then then cr loop ;
fizz
5 sq . cr
: fact dup 1 > if dup 1 - fact * then ;
10 fact . cr
: cd 5 begin dup . 1 - dup 0 = until drop cr ;
cd
