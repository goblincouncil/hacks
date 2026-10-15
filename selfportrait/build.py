# Writes selfportrait.py from body.txt: s='''<body>'''\n<body>
import os
here = os.path.dirname(os.path.abspath(__file__))
body = open(os.path.join(here, "body.txt")).read()
assert "\\" not in body, "body may not contain a backslash"
assert "'''" not in body, "body may not contain triple quotes"
assert body.endswith("\n") and body.isascii()
open(os.path.join(here, "selfportrait.py"), "w").write("s='''" + body + "'''\n" + body)
