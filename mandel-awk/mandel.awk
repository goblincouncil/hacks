# Mandelbrot in integer fixed-point (scale 4096). usage: awk -f mandel.awk [-v W=60 -v H=24 -v N=40]
BEGIN {
  if (!W) W = 60; if (!H) H = 24; if (!N) N = 40
  S = 4096; pal = " .:-=+*#%@"
  for (y = 0; y < H; y++) {
    line = ""
    for (x = 0; x < W; x++) {
      cr = int((-2.5 * S) + int(x * 3.5 * S / W))
      ci = int((-1.0 * S) + int(y * 2.0 * S / H))
      zr = 0; zi = 0; i = 0
      while (i < N) {
        zr2 = int(zr * zr / S); zi2 = int(zi * zi / S)
        if (zr2 + zi2 > 4 * S) break
        t = int(2 * zr * zi / S) + ci
        zr = zr2 - zi2 + cr; zi = t; i++
      }
      line = line substr(pal, (i >= N) ? 10 : 1 + int(i * 9 / N), 1)
    }
    print line
  }
}
