# Log
- Wrote the script and checker in one go. Optimality is checked by total bits, not by code equality, since tie-breaking differs between implementations.
- Single-symbol input needs a 1-bit code ("0"), added as a special case.
- Sabotage: flipping the comparisons to pick the heaviest nodes gives a valid but non-optimal code; the checker catches it.
