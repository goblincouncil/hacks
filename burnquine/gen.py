# Builds burnquine.py from body.py: wraps the body in s=<repr> and exec(s).
import os, sys
here = os.path.dirname(os.path.abspath(__file__))
body = open(os.path.join(here, 'body.py')).read()
sys.stdout.write('s=' + repr(body) + '\nexec(s)\n')
