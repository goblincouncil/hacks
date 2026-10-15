# jqray

A ray tracer written in jq, the JSON query tool. It renders a green mirror ball
hovering over a red and white checkered floor, with a shadow, a specular
highlight, two bounces of reflection and distance fog, and prints the result as
a plain-text PPM image.

## Run it

    jq -n -r -f jqray.jq > ball.ppm                                  # 160x120, about 1.2 s
    jq -n -r --argjson w 320 --argjson h 240 -f jqray.jq > big.ppm   # about 5 s

Most image viewers open PPM directly. To get a PNG: `magick ball.ppm ball.png`.

Test it:

    sh check.sh

## How it works

- Vectors are JSON arrays `[x, y, z]`. `vadd`, `vsub`, `vmul`, `vdot` and
  `vnorm` are small jq `def`s.
- For each pixel a ray leaves the camera. `sphere` solves the ray-sphere
  quadratic, `floorhit` intersects the plane y = 0, and the nearer hit wins.
- The ball gets diffuse light plus a highlight (the light term raised to the
  32nd power by squaring five times). The floor colour comes from
  `floor(x) + floor(z)` being odd or even, and a shadow ray towards the light
  darkens it if the ball is in the way.
- Reflection is `trace` calling itself with the bounced ray, two levels deep.
  jq has no loops in the usual sense, so recursion is the natural fit.
- Colours are gamma corrected with `sqrt`, scaled to 0..255, and the image is
  emitted as text lines: `P3`, the size, `255`, then one line per row.
- Size comes in through `$ARGS.named`, so `w` and `h` are optional.

## Files

- `jqray.jq`: the tracer.
- `twin.py`: an independent Python version of the same scene, written to do the
  same arithmetic in the same order.
- `check.sh`: renders with jq, compares byte for byte with the twin at two sizes,
  checks that the picture has a sky, a green ball and red tiles, and confirms
  that five sabotaged copies of the tracer no longer match.

Needs jq (tested with 1.8.1) and python3 for the check.

MIT license.
