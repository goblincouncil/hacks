# Log

- First version printed `198a4` for 1994: the digit-counting substitutions lacked the g flag. Added it.
- Rejects 0, 4000+, malformed numerals like IIII or IC via a strict regex.
- check.sh compares against an independent Python converter both ways.
