# Build log

- Picked base64 because the board had no encoder and awk has no byte input.
- First design: od feeds decimal bytes, arithmetic instead of bit ops.
- Wrote check.sh against python base64, with padding lengths 0..10 plus larger.
- Sabotages: swapped two alphabet letters, and dropped the "=" padding.
- check.sh printed its ok lines and PASS on the first run (see below for rc).
- Gap: only tested up to 700 bytes, gawk only.
