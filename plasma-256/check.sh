#!/bin/sh
# Exits 0 only if hack/intro.html is <= 256 bytes and its script really
# animates a plasma: it is run in Node against a fake canvas, two frames are
# drawn, and the pixels are counted and compared.
set -eu
cd "$(dirname "$0")"
f=intro.html
[ -f "$f" ] || { echo "FAIL: $f missing"; exit 1; }
n=$(wc -c < "$f" | tr -d ' ')
[ "$n" -le 256 ] || { echo "FAIL: $f is $n bytes, limit is 256"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "FAIL: node not found"; exit 1; }

F="$f" node <<'EOF'
const fs = require('fs'), vm = require('vm');
const fail = m => { console.log('FAIL: ' + m); process.exit(1); };
const html = fs.readFileSync(process.env.F, 'utf8');
if (!/<canvas[^>]*\bid=c\b/.test(html)) fail('no <canvas id=c>');
const m = html.match(/<script>([\s\S]*?)<\/script>/);
if (!m) fail('no <script> block');

let frame = null, cb = null, delay = null;
const ctx = {
  _s: '',
  set fillStyle(v) { this._s = String(v); },
  get fillStyle() { return this._s; },
  fillRect(x, y) { frame.set(Math.floor(x) + ',' + Math.floor(y), this._s); },
};
const c = { getContext() { return ctx; } };
const sb = { c, Math, setInterval(f, d) { cb = f; delay = d; return 1; } };
vm.createContext(sb);
try { vm.runInContext(m[1], sb, { timeout: 5000 }); } catch (e) { fail('script threw: ' + e.message); }
if (typeof cb !== 'function') fail('no animation loop (setInterval never called)');

const draw = () => { frame = new Map(); try { cb(); } catch (e) { fail('frame threw: ' + e.message); } return frame; };
const a = draw(), b = draw();
if (a.size < 10000) fail('only ' + a.size + ' pixels drawn per frame');
const colours = new Set(a.values()).size;
if (colours < 1000) fail('only ' + colours + ' distinct colours');
let changed = 0;
for (const [k, v] of a) if (b.get(k) !== v) changed++;
if (changed < a.size / 2) fail('only ' + changed + ' of ' + a.size + ' pixels change between frames');
console.log('PASS: ' + a.size + ' pixels/frame, ' + colours + ' colours, ' + changed +
  ' pixels change between frames, interval ' + delay + 'ms');
EOF
