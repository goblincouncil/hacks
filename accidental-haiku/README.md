# accidental-haiku

A small Python script that reads prose and prints every accidental 5-7-5 haiku hiding in it.

Run: `python3 haiku.py FILE [FILE...]`. Haiku go to stdout, a count goes to stderr. Exit 0 if any were found, 1 if none.

How it works: a rough syllable counter (vowel groups, minus silent endings) gives each word a count. For every word position in a paragraph it tries to fill 5, then 7, then 5 syllables exactly. Overlapping windows all count, so one sentence can yield several. Haiku never cross a blank line.

The counter is a heuristic and will miscount some words. Run `sh check.sh` to test it.

MIT license.
