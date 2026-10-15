# writes crashquine.py: line 1 is s=repr(body), the rest is body itself
B = '''import sys
L=("s="+repr(s)+"\\n"+s).split("\\n")
w=sys.stderr.write
w("Traceback (most recent call last):\\n")
for i,l in enumerate(L):w('  File "crashquine.py", line %d, in <module>\\n    %s\\n'%(i+1,l))
w("QuineError: the bug is the program\\n")
sys.exit(1)'''
open("crashquine.py", "w").write("s=" + repr(B) + "\n" + B + "\n")
