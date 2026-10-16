# vigenere-awk

Vigenere encrypt and decrypt in one small awk script.

    echo "Attack at dawn" | awk -v key=lemon -f vigenere.awk
    echo "Lxfopv ef rnhr" | awk -v key=lemon -v mode=dec -f vigenere.awk

Case is kept. Non-letters pass through and do not advance the key. A key that is empty or has non-letters prints `?` and exits 1.

How it works: letters are found with `index()` in the alphabet, shifted by the key letter, and wrapped with `((x % 26) + 26) % 26` so decryption never goes negative.

Test: `sh check.sh` compares 200 random lines, 4 keys, both modes against an independent Python version, checks round-trips and the classic LEMON vector, and requires a sabotaged copy to fail.

Gap: ASCII letters only.

MIT license.
