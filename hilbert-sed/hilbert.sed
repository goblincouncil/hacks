# hilbert.sed: grow the Hilbert curve L-system with sed alone.
# Input: one line holding the order, a single digit 1-9.
# Output: one line of turtle commands, F = forward, + = left, - = right.
# Rules: A -> +BF-AFA-FB+   B -> -AF+BFB+FA-
/^[1-9]$/!{
  s/.*/hilbert.sed: order must be a single digit 1-9/
  w /dev/stderr
  Q 2
}
# turn the digit into a row of i marks, one per generation
:count
/^0/!{
  y/123456789/012345678/
  s/$/i/
  bcount
}
s/^0/A;/
# one generation per mark. Park A and B as X and Y first, so a rule
# never rewrites letters that the other rule just produced.
:grow
/i$/{
  s/i$//
  s/A/X/g
  s/B/Y/g
  s/X/+BF-AFA-FB+/g
  s/Y/-AF+BFB+FA-/g
  bgrow
}
s/;$//
s/[AB]//g
# cancel turns that undo each other
:tidy
s/+-\|-+//g
ttidy
