# Build log

- First idea was bc. No bc or dc installed here, so I switched to awk with integer fixed-point.
- Wrote mandel.awk and ref.py (Python, same truncating integer math). check.sh diffs the two outputs.
- check.sh passes, and the picture looks like a Mandelbrot set.
- Attempt 1 left only code and no README or LOG, so the done check failed. Docs written in attempt 2.
- Gap: fixed view window, and ref.py only checks the default size.
