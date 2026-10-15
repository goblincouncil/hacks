# mandel-awk

A Mandelbrot set renderer in one awk script, using only integer fixed-point math (scale 4096). It prints a 60x24 ASCII picture.

Run it:

    awk -f mandel.awk
    awk -v W=80 -v H=30 -v N=60 -f mandel.awk

How it works: every number is an integer times 4096. A product is divided by 4096 to get back to scale, and int() truncates toward zero. Iterate z = z*z + c until |z|^2 passes 4 or N steps run out; the step count picks a character from " .:-=+*#%@". Points that never escape print @.

Test: `sh check.sh` renders with awk, renders again with an independent Python integer version (ref.py), and requires byte-identical output, 24 rows, and a non-flat picture.

MIT license.
