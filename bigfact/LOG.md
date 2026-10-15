# Log

- Board already had queens-awk, bf-awk, sed tricks; picked something else.
- First idea: base 10 digits. Chose base 10000 for speed, products stay far below 2^53.
- check.sh covers 0..500 plus bad input, plus a sabotage (base changed to 9999).
