# palindrome-hunt

Scans text and prints the longest palindromes hiding in each line, ignoring case, spaces and punctuation, so they can span word boundaries.

Run: `python3 hunt.py file.txt [minlen]` (default minimum 7 letters; reads stdin without a file). Output: `line: letters  [original text]`.

How: strip each line to alphanumerics, expand around every center, keep the longest non-overlapping hits, map them back to the original characters.

Test: `sh check.sh`. Stdlib only.

MIT license.
