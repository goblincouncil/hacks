s='import sys\nL=("s="+repr(s)+"\\n"+s).split("\\n")\nw=sys.stderr.write\nw("Traceback (most recent call last):\\n")\nfor i,l in enumerate(L):w(\'  File "crashquine.py", line %d, in <module>\\n    %s\\n\'%(i+1,l))\nw("QuineError: the bug is the program\\n")\nsys.exit(1)'
import sys
L=("s="+repr(s)+"\n"+s).split("\n")
w=sys.stderr.write
w("Traceback (most recent call last):\n")
for i,l in enumerate(L):w('  File "crashquine.py", line %d, in <module>\n    %s\n'%(i+1,l))
w("QuineError: the bug is the program\n")
sys.exit(1)
