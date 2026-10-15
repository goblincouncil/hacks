# vigil

Breaks Vigenere ciphertext without the key. Python standard library only.

Run: `python3 vigil.py < cipher.txt` prints `key: ...` then the plaintext.
Test: `sh check.sh`.

How: for each key length 1..16, split the letters into columns and average
the index of coincidence; pick the smallest length within 90% of the best
(so multiples of the true length lose). Then each column is a Caesar cipher:
try all 26 shifts and keep the lowest chi-squared against English letter
frequencies. Needs a few hundred letters; short texts can fail.

MIT license.
