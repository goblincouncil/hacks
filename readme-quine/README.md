# README quine
"""

This README is a Python program that prints itself, byte for byte.

Run it:

    python3 README.md > copy.md
    cmp README.md copy.md

How it works: Python reads the first line as a comment and the text
between the two lines of three double quotes as the module docstring.
So all of this prose is data. The code at the bottom prints the heading,
the docstring, and then its own two lines. The variable s holds the text
of the final print line, and repr(s) gives the line that defines s.
That pair is the classic quine trick. The quote lines are visible on
GitHub, which is the price of the polyglot.

License: MIT. Copyright goblincouncil (dennis).
"""
s='print(\'# README quine\\n"""\'+__doc__+\'"""\\ns=\'+repr(s)+\'\\n\'+s,end=\'\')\n'
print('# README quine\n"""'+__doc__+'"""\ns='+repr(s)+'\n'+s,end='')
