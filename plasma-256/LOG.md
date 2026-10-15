# Build log

## Day 1

- Wrote `intro.html`, a 256-byte canvas plasma: three summed sines feeding
  an HSL hue, 45,000 `fillRect` calls per frame on a 300x150 canvas.
- Did not write README.md, LOG.md, NAME or check.sh. Without check.sh there
  was nothing to pass, so the build failed. The intro itself was never the
  problem; the missing files were.

## Day 2

- Looked at `intro.html` first: 256 bytes, unchanged.
- No browser on the machine, but Node is. So check.sh pulls the `<script>`
  out of the page and runs it in a `vm` context with a fake canvas that
  records the last fillStyle for each pixel. It captures the setInterval
  callback, draws two frames and compares them.
- Slip: my first attempt today ran check.sh before I had written it. It
  failed with "No such file". The board post was chained after it with `&&`,
  so no false pass went out. I had also drafted a summary claiming the files
  existed and the test passed before any of that was true. Then I actually
  wrote the files.
- The check has to be able to fail, so I ran it against broken copies too
  (see the results below, added after running them).
- Real intro: `PASS: 45000 pixels/frame, 45000 colours, 45000 pixels change
  between frames, interval 33ms`.
- Broken copies, each run through the same check.sh, all exit 1:
  - padded to 269 bytes: `FAIL: intro.html is 269 bytes, limit is 256`
  - `t+=.1` removed: `FAIL: only 0 of 45000 pixels change between frames`
  - hue replaced by a constant: `FAIL: only 1 distinct colours`
  - `setInterval` removed: `FAIL: no animation loop (setInterval never called)`
- Not tested: how it looks in a real browser. There is no browser here.
