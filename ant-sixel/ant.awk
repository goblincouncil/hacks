# ant.awk: Langton's ant, printed as a DEC sixel image.
# usage: awk -v steps=11000 -v scale=4 -f ant.awk > ant.six ; cat ant.six
# Plain POSIX awk. No input is read.
BEGIN {
    if (steps == "") steps = 11000
    if (scale == "") scale = 4
    # ant at 0,0 facing up. dir: 0 up, 1 right, 2 down, 3 left.
    # y grows downward, like the picture.
    dx[0] = 0; dy[0] = -1; dx[1] = 1; dy[1] = 0
    dx[2] = 0; dy[2] = 1;  dx[3] = -1; dy[3] = 0
    x = y = d = 0; x0 = x1 = y0 = y1 = 0
    for (i = 0; i < steps; i++) {
        k = x "," y
        if (k in on) { d = (d + 3) % 4; delete on[k] }   # black: turn left, flip
        else         { d = (d + 1) % 4; on[k] = 1 }      # white: turn right, flip
        x += dx[d]; y += dy[d]
        if (x < x0) x0 = x; if (x > x1) x1 = x
        if (y < y0) y0 = y; if (y > y1) y1 = y
    }
    # one cell of margin all round
    x0--; y0--; x1++; y1++
    W = (x1 - x0 + 1) * scale; H = (y1 - y0 + 1) * scale
    printf "\033P0;1;0q\"1;1;%d;%d", W, H
    printf "#0;2;95;90;75#1;2;15;10;25#2;2;90;15;10"   # paper, ink, ant
    for (by = 0; by < H; by += 6) {
        for (c = 0; c <= 2; c++) {
            line = ""; prev = ""; run = 0; any = 0
            for (px = 0; px < W; px++) {
                bits = 0
                for (r = 0; r < 6 && by + r < H; r++)
                    if (color(px, by + r) == c) bits += 2 ^ r
                if (bits) any = 1
                ch = sprintf("%c", 63 + bits)
                if (ch == prev) run++
                else { line = line emit(prev, run); prev = ch; run = 1 }
            }
            line = line emit(prev, run)
            if (any) printf "#%d%s$", c, line
        }
        printf "-"
    }
    printf "\033\\\n"
}
function color(px, py,   cx, cy) {
    cx = x0 + int(px / scale); cy = y0 + int(py / scale)
    if (cx == x && cy == y) return 2
    return ((cx "," cy) in on) ? 1 : 0
}
function emit(ch, n) {
    if (n == 0) return ""
    if (n > 3) return "!" n ch
    return n == 1 ? ch : n == 2 ? ch ch : ch ch ch
}
