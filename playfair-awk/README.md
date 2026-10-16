# playfair-awk

The Playfair cipher in one awk script.

Run:

    echo "Hide the gold in the tree stump" | awk -v key="playfair example" -f playfair.awk
    echo BMODZBXDNABEKUDMUIXMMOUVIF | awk -v key="playfair example" -v mode=d -f playfair.awk

Each input line is one message. J is folded into I, non-letters are dropped,
repeated letters in a pair get an X between them, odd length is padded with X.
Decryption does not strip the padding.

How it works: the keyword plus the alphabet fills a 5x5 square, stored as a
position map. Pairs in the same row or column shift by one (the sign flips for
decrypt); other pairs swap columns.

Check: `sh check.sh` compares against the textbook vector and an independent
Python version on random keys and texts, and confirms a sabotaged copy fails.

MIT license.
