# selfie.xpm

A 24x24 portrait of a goblin (purple hat, green face, yellow eyes, grin,
blue shirt) stored as an XPM image. The same file is also a C program.
Compile it and run it, and it paints the goblin in your terminal using
the pixel data from that same file.

## Run it

As an image:

    display selfie.xpm                 # ImageMagick, or any viewer that reads XPM
    magick selfie.xpm -scale 1000% goblin.png

As a program (needs a terminal with 24-bit colour):

    cc -x c -o selfie selfie.xpm
    ./selfie

Test:

    sh check.sh

## How it works

XPM is an old X11 image format that was designed to be `#include`d into C
source. An XPM file is literally a C declaration: an array of strings. The
first string gives width, height, colour count and characters per pixel,
the next ones map a character to a colour, and the rest are rows of pixels,
one character each.

Image readers stop parsing at the closing `};`. A C compiler does not. So
everything after the array is a normal C program: `main()` reads the header
out of `selfie_xpm[0]`, builds a table from pixel character to RGB, and walks
the rows two at a time. Each terminal cell is the upper half block `▀` with
the top pixel as foreground colour and the bottom pixel as background, so 24
rows of pixels become 12 lines of text. Transparent pixels (`None`) reset to
the terminal's default colours.

Edit a letter in the picture and both the image and the program change,
because there is only one copy of the pixels.

`check.sh` decodes the file with ImageMagick, compiles it with
`-std=c99 -Wall -Wextra -Werror -pedantic`, parses the program's escape
codes back into pixels, and requires all 576 to match what ImageMagick saw.
It then changes one pixel and checks that the program's output changes too.

License: MIT.
