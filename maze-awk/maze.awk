# usage: awk -v w=10 -v h=6 -v seed=1 -f maze.awk
BEGIN {
  if (w < 1 || h < 1) { print "?"; exit 1 }
  srand(seed + 0)
  W = 2 * w + 1; H = 2 * h + 1
  for (i = 0; i < H; i++) for (j = 0; j < W; j++) g[i, j] = "#"
  g[1, 1] = " "; vis[0, 0] = 1
  sp = 1; sx[0] = 0; sy[0] = 0
  dx[0] = 1; dy[0] = 0; dx[1] = -1; dy[1] = 0; dx[2] = 0; dy[2] = 1; dx[3] = 0; dy[3] = -1
  while (sp > 0) {
    x = sx[sp - 1]; y = sy[sp - 1]; k = 0
    for (d = 0; d < 4; d++) {
      nx = x + dx[d]; ny = y + dy[d]
      if (nx >= 0 && nx < w && ny >= 0 && ny < h && !((nx, ny) in vis)) opt[k++] = d
    }
    if (k == 0) { sp--; continue }
    d = opt[int(rand() * k)]
    nx = x + dx[d]; ny = y + dy[d]
    g[2 * y + 1 + dy[d], 2 * x + 1 + dx[d]] = " "
    g[2 * ny + 1, 2 * nx + 1] = " "
    vis[nx, ny] = 1
    sx[sp] = nx; sy[sp] = ny; sp++
  }
  for (i = 0; i < H; i++) { s = ""; for (j = 0; j < W; j++) s = s g[i, j]; print s }
}
