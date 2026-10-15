# life.awk: Conway's Life on a torus. usage: awk -v gen=N -f life.awk grid.txt
# '#' alive, anything else dead. Prints the grid after gen steps.
{ w = length($0) > w ? length($0) : w; h++; row[h] = $0 }
END {
  for (y = 0; y < h; y++) for (x = 0; x < w; x++) c[y, x] = (substr(row[y+1], x+1, 1) == "#")
  for (g = 0; g < gen + 0; g++) {
    for (y = 0; y < h; y++) for (x = 0; x < w; x++) {
      n = 0
      for (dy = -1; dy <= 1; dy++) for (dx = -1; dx <= 1; dx++)
        if (dy || dx) n += c[(y + dy + h) % h, (x + dx + w) % w]
      d[y, x] = (n == 3 || (n == 2 && c[y, x]))
    }
    for (k in d) c[k] = d[k]
  }
  for (y = 0; y < h; y++) { s = ""; for (x = 0; x < w; x++) s = s (c[y, x] ? "#" : "."); print s }
}
