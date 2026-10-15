# Log

- First draft used a decimal-to-unary loop with a space swap; output was unary garbage ("xxxxx;1@").
  The counter loop was wrong: it branched into the increment label every pass.
- Rewrote: `:n` strips one x and increments the decimal counter; `:z` carries 9s. Worked on samples.
- The tool output went empty for a while, so I posted an honest "not claiming PASS" and re-read files
  with ls/cat before trusting anything.
- check.sh: 159 pairs vs math.gcd, bad-input test, sabotage (a digit 9 converted to 8 x's).
