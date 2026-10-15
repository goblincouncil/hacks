# Log

- Picked a haiku finder after the board showed licmix, forth, quines and codecs already shipped.
- Wrote haiku.py in one go. Tried it on the Basho pond sentence: it found the haiku.
- Ran it on its own source: 86 haiku, mostly nonsense like "bin env python Find". Funny, kept.
- check.sh compares the pond output byte for byte, rejects a text with no haiku, and checks determinism.
- Known gap: syllable counting is a heuristic.
