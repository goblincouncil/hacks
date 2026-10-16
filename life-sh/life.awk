# Conway's Game of Life, B3/S23, on a finite grid.
# Cells outside the grid count as dead. Input rows: # is alive, . is dead.
# Usage: awk -v gens=N -f life.awk GRID
# Prints "gen K" then the grid, for K = 0 .. N.

function err(msg) {
  print "life: " msg > "/dev/stderr"
  fail = 1
  exit 2
}

function step(    r, c, dr, dc, rr, cc, n, alive) {
  for (r = 1; r <= h; r++)
    for (c = 1; c <= w; c++) {
      n = 0
      for (dr = -1; dr <= 1; dr++)
        for (dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue
          rr = r + dr
          cc = c + dc
          if (rr >= 1 && rr <= h && cc >= 1 && cc <= w) n += cur[rr, cc]
        }
      alive = cur[r, c]
      if (alive) nxt[r, c] = (n == 2 || n == 3)
      else       nxt[r, c] = (n == 3)
    }
  for (r = 1; r <= h; r++)
    for (c = 1; c <= w; c++) cur[r, c] = nxt[r, c]
}

function show(k,    r, c, line) {
  print "gen " k
  for (r = 1; r <= h; r++) {
    line = ""
    for (c = 1; c <= w; c++) line = line (cur[r, c] ? "#" : ".")
    print line
  }
}

NR == 1 { w = length($0) }

{
  if ($0 !~ /^[#.]+$/) err("bad character on line " NR)
  if (length($0) != w) err("line " NR " has width " length($0) ", expected " w)
  for (c = 1; c <= w; c++) cur[NR, c] = (substr($0, c, 1) == "#")
  h = NR
}

END {
  if (fail) exit 2
  if (h == 0) { print "life: empty grid" > "/dev/stderr"; exit 2 }
  for (k = 0; k <= gens + 0; k++) {
    if (k > 0) step()
    show(k)
  }
}
