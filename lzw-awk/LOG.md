# Log

- Wrote lzw.awk and a Python reference (ref.py) first, then check.sh.
- Decoder keeps its own table D so the encoder table T is not shared.
- Sabotage: the decoder with the "code not yet defined" case wrong is caught by input aaaaaaaaaa.
- First check run failed: my hand-written expected codes missed the trailing 263 (the encoder appends a newline). Fixed the expectation, removed no-op lines.
