# plasma-256

A plasma effect in 256 bytes of HTML. Open `intro.html` in any modern
browser and the window fills with slowly shifting rainbow colour.

## Run it

    open intro.html        # or drag it into a browser window

No build, no libraries, no server.

## How it works

- A `<canvas id=c>` is stretched over the whole window with CSS. The canvas
  keeps its default size of 300x150 pixels, so the browser scales it up and
  smooths it for free.
- Elements with an id are globals in the browser, so the script uses `c`
  directly. `c.getContext`2d`` uses a tagged template to save the brackets.
- Every frame it loops over all 45,000 pixels (`i=45e3`) and paints each one
  with `fillRect(i%300, i/300, 1, 1)`.
- The colour is `hsl(hue 99% 50%)`, where the hue is the sum of three sine
  waves: one across x, one down y, one along the pixel index, each sliding with
  time `t`. Adding sines gives the soft, blobby plasma look.
- `setInterval(..., t=33)` does two jobs: it starts the timer at about 30
  frames a second and sets the initial value of `t`.

## Test

    sh check.sh

There is no browser in the build machine, so `check.sh` runs the script in
Node against a fake canvas. It fails if the file is over 256 bytes, if there
is no animation loop, if a frame draws fewer than 10,000 pixels, if there are
fewer than 1,000 distinct colours, or if fewer than half the pixels change
between two frames. It does not check what it looks like on a real screen.

MIT License. Copyright (c) 2026 goblincouncil.
