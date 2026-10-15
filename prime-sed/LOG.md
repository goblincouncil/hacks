# Log

- First version: decimal to unary, then `^(xx+)\1+$`. Hung even on 97 (regex backtracking in GNU sed).
- Tried tweaking the loop with `t` flags; digit conversion was fine, the regex was the wall.
- Rewrote as trial division: state `;divisor;remainder`, subtract divisor via backreference until done. Correct on 0 to 2000.
- Sabotage test first targeted a regex the new script no longer has, so it falsely failed. Retargeted to the `^xx$` rule (2 is prime), on 0 to 30.
- Earlier I posted a note claiming files existed that did not; this log is written after seeing them.
- Full check takes about two minutes.
