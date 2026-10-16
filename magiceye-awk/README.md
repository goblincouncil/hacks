# magiceye-awk

One awk script that turns a depth map made of digits into a text
autostereogram, the Magic Eye kind. Look through the screen (or cross your
eyes slightly) until neighbouring columns of letters line up, and the shapes
in the map float up out of the noise.

## Run it

    awk -f magiceye.awk goblin.map
    awk -v P=20 -v seed=7 -f magiceye.awk goblin.map

The map is plain text: one row per line, each character a depth from 0 (far)
to 9 (near). A dot or a space also means 0, and short rows are padded with 0.
Anything else is refused with exit 1.

Options:

- `P` is the pattern period in characters, 10 to 99, default 16. Wider
  periods are easier to fuse on a wide terminal.
- `seed` picks the random letters, 1 to 2147483646, default 1. Same seed,
  same picture.

Each output row is P + (map width) letters long. `goblin.map` is a sample: a
flat disc at depth 6 between two pillars at depth 3.

## How it works

Each row starts with P random letters (a Park-Miller generator, so the output
is repeatable). Every later letter copies the one P - d places to its left,
where d is the depth under it:

    c[x] = c[x - P + d]

That is the whole trick. When your eyes fuse columns P apart, places where
the repeat is shorter look nearer, so the digits become height.

## Checking it

`sh check.sh` runs everything below and prints PASS only if all of it holds:

- `twin.py` is a separate Python version written from the rule, not from the
  awk. The awk output must match it byte for byte on the sample and on 30
  random maps at different periods and seeds.
- `decode.py` is a blind decoder. It only sees the letters, and for each one
  asks which repeat distance points back at the same letter. It must recover
  the sample map exactly, and at least 99 percent of cells on the random maps.
  It can miss a few cells at depth edges, because with 52 letters a wrong
  distance sometimes matches by luck.
- A corrupted letter must show up as `?` in the decoder output.
- Bad maps, bad periods and bad seeds must exit 1 with no output.
- Six sabotaged copies of the script (wrong sign, no depth, smaller alphabet,
  changed generator, off-by-one read, short row) must all be caught.

Needs awk and python3. Nothing else.

## Files

- `magiceye.awk` the generator
- `goblin.map` sample depth map
- `twin.py` independent Python generator
- `decode.py` blind decoder
- `gen_maps.py` random test maps for check.sh
- `check.sh` the test

MIT License. Copyright (c) 2026 goblincouncil.
