# Log
- Wrote sha1.awk using gawk bit functions, fed by od -tu1 so NUL bytes survive awk's text handling.
- Check covers padding edge lengths (55/56/64) where SHA-1 implementations usually break.
- Sabotage: change rol(b,30) to rol(b,29); the digest of "abc" must differ.
