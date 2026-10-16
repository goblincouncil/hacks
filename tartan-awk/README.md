# tartan-awk

A loom in one awk script. You give it a tartan threadcount and it weaves the cloth as a PPM image.

## Run it

    awk -v sett='K4 R24 K24 Y4' -f tartan.awk > cloth.ppm
    awk -v sett='B24 K4 B4 K4 B4 K24 G24 Y6' -v size=400 -f tartan.awk > cloth.ppm

Open cloth.ppm in any image viewer, or turn it into a PNG with `magick cloth.ppm cloth.png`.

`size` is the width and height in threads (one pixel per thread). The default is 240 and the limit is 4000.

To run the test: `sh check.sh`. It prints one `ok` line per test and ends with PASS or FAIL.

## The threadcount

A sett is a list of stripes. Each stripe is a colour letter followed by a thread count: `K4` means four black threads. The colours are:

    K black   W white   R red     G green   B blue
    Y yellow  N navy    P purple  O orange  A grey

The colour values are my own picks, not an official standard.

Tartan setts are symmetric. The loom weaves the list forward, then backward, and counts the first and last stripes once each, because they are the pivots of the mirror. So `K4 R24 K24 Y4` repeats every 4+24+24+4+24+24 = 104 threads.

The same sett is used for warp (vertical threads) and weft (horizontal threads), which is how most tartans are woven.

Bad input is refused with a message on stderr, exit status 1, and nothing on stdout: lowercase letters, unknown colours, zero counts, missing counts, or a size that is not a number.

## How it works

There are two steps. First the sett is expanded into one list of thread colours, mirrored as described above.

Then the weave. In a 2/2 twill each weft thread passes over two warp threads, then under two, and every row is shifted by one. The whole pattern is one rule:

    (x + y) % 4 < 2

Where it holds, the warp thread at column x is on top and its colour shows. Elsewhere the weft thread at row y shows. That shift is what makes the diagonal ribs you see in real tartan, and where two stripes cross you get the mixed checks.

## How it is tested

`check.sh` compares the awk loom against `loom.py`, a separate Python loom that does the same job a different way: the mirror is a list slice, and the weave is a 4x4 lift plan table instead of a formula. Ten setts at three sizes must match byte for byte. It also checks the image header, has ImageMagick read the image, checks a solid single-colour cloth and one row worked out by hand, feeds it bad input, and runs six sabotaged copies of the loom that must all be caught.

## Limits

Square cloth only, the same sett both ways, 2/2 twill only, and one pixel per thread. The output is plain-text PPM (P3), so big images are big files.

MIT license.
