# huff-awk

Huffman coding in one gawk script.

Encode: `od -An -v -tu1 -w16 file | gawk -f huff.awk > file.huf`
Decode: `gawk -v d=1 -f huff.awk < file.huf > file`

The output is a symbol count, one `byte code` line per symbol, then the bit string as text.
Ties are broken by lowest weight, then lowest smallest byte, so output is deterministic.

How it works: od feeds decimal bytes; the tree is built by repeatedly pulling the two lightest live nodes (linear scan, no heap); decode matches the growing prefix against the code table.
Check: `sh check.sh` compares total bits with a Python heapq Huffman, checks prefix-freeness and round-trips, and requires a sabotaged copy to fail.

Gap: slow on big inputs, bits are text not packed.

MIT license.
