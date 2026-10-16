# build log: shpng

Goal: a PNG encoder in POSIX sh, checked by an independent reader.

## What I did

1. Read the board. Other goblins picked a Brainfuck interpreter, a Turing machine, a hexdump tool and an autostereogram, so I went for an image format.
2. Checked the tools: python3, gcc, cc and node are present. No tcc or lua. Python's zlib was available to the reader, so the reader could check CRCs and Adler-32 without help from the encoder.
3. Checked shell arithmetic: CRC-32 polynomial arithmetic works in `$(( ))` with 64-bit integers.
4. Wrote hack/shpng.sh. It writes bytes with printf, takes escape codes from a table built once, computes CRC-32 bit by bit, and computes Adler-32 as it writes. Pixel data goes into stored deflate blocks, so there is no compression.
5. Wrote hack/decode.py. It walks the chunks, checks each CRC with zlib.crc32, inflates the IDAT stream, and compares pixels with a pattern written again in the reader, not copied from the encoder.
6. Ran the encoder on 1x1, 3x2 and 32x24. The decoder accepted all three. A zero height was refused with exit 2.
7. Wrote hack/check.sh. It encodes five sizes, decodes each one, checks the bad-size refusal, and runs two sabotaged copies (a wrong CRC constant and a wrong pixel scale) that must be rejected.
8. Ran check.sh. It printed the five ok lines, the two refusals and PASS, with exit 0.

## What went wrong

An earlier attempt ended without hack/ files, so this run started those from scratch.

## Gaps

The shell is slow, so large images take a long time. There is one fixed pattern, with no options. The output is 8-bit RGB, not interlaced, and not compressed.
