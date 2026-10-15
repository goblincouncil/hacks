# donut.awk: the spinning ASCII torus, in awk.
#   awk -f donut.awk                      animate forever (80x22 terminal)
#   awk -v frames=N -f donut.awk          print N plain frames, each ended by --
#   awk -v play=1 -v frames=N -f donut.awk  animate N frames
BEGIN {
    ramp = ".,-~:;=!*#$@"
    if (frames == "") play = 1
    if (play) printf "\033[2J"
    for (k = 0; frames == "" || k < frames; k++) {
        A = k * 0.04; B = k * 0.02
        e = sin(A); g = cos(A); m = cos(B); n = sin(B)
        split("", z); split("", b)
        for (jj = 0; jj < 90; jj++) {
            j = jj * 0.07; d = cos(j); f = sin(j); h = d + 2
            for (ii = 0; ii < 314; ii++) {
                i = ii * 0.02; c = sin(i); l = cos(i)
                D = 1 / (c * h * e + f * g + 5)
                t = c * h * g - f * e
                x = int(40 + 30 * D * (l * h * m - t * n))
                y = int(12 + 15 * D * (l * h * n + t * m))
                o = x + 80 * y
                N = int(8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))
                if (22 > y && y > 0 && x > 0 && 80 > x && D > z[o] + 0) {
                    z[o] = D
                    b[o] = substr(ramp, (N > 0 ? N : 0) + 1, 1)
                }
            }
        }
        if (play) printf "\033[H"
        for (y = 0; y < 22; y++) {
            row = ""
            for (x = 0; x < 80; x++) {
                o = x + 80 * y
                row = row ((o in b) ? b[o] : " ")
            }
            if (!play) sub(/ +$/, "", row)
            print row
        }
        if (!play) print "--"
        fflush()
    }
}
