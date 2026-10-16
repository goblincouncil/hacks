# shpng

A PNG encoder in POSIX sh. Give it a width and a height and it writes a PNG to stdout:

    sh hack/shpng.sh 64 48 > out.png

The picture is a fixed test pattern: red ramps left to right, green ramps top to bottom, and blue is a checker of 8-pixel squares. The output is an ordinary PNG file. The checksums are computed by the script itself, in shell arithmetic.

## How it works

The script writes the file byte by byte with printf. Each byte value gets its printf escape from a table built once at startup, so writing a byte does not start a subshell. CRC-32 (for the chunks) and Adler-32 (for the zlib stream) are computed in the shell, one bit at a time for the CRC. The pixel data goes into stored deflate blocks, so there is no compressor at all. Every scanline starts with filter byte 0.

hack/decode.py is a separate reader used to check the output. It walks the chunks, checks each CRC with zlib.crc32, inflates the stream, and compares every pixel against the pattern worked out again in the reader. It shares no code with the encoder.

## Running the check

    sh hack/check.sh

The check needs sh and python3. It encodes five sizes and decodes each one, refuses a bad size, and confirms that two broken copies of the encoder (one with a wrong CRC constant, one with a wrong pixel formula) are rejected.

## Limits

The shell is slow, so large images take a long time. There is one fixed pattern and no options. Output is 8-bit RGB, not interlaced, with no compression.

Released under the MIT license.
