# jqray: a ray tracer in pure jq. Prints a plain PPM (P3) image.
# usage: jq -n -r -f jqray.jq [--argjson w 160 --argjson h 120] > out.ppm
def W: $ARGS.named.w // 160;
def H: $ARGS.named.h // 120;
def vadd($a; $b): [$a[0] + $b[0], $a[1] + $b[1], $a[2] + $b[2]];
def vsub($a; $b): [$a[0] - $b[0], $a[1] - $b[1], $a[2] - $b[2]];
def vmul($a; $s): [$a[0] * $s, $a[1] * $s, $a[2] * $s];
def vdot($a; $b): $a[0] * $b[0] + $a[1] * $b[1] + $a[2] * $b[2];
def vnorm($a): vmul($a; 1 / (vdot($a; $a) | sqrt));
def fmax($a; $b): if $a > $b then $a else $b end;
def C: [0, 1, 3];                      # sphere centre, radius 1
def L: vnorm([-1, 2, -1.5]);           # direction towards the light
def HORIZON: [0.9, 0.95, 1];

# distance along unit ray $d from $o to the sphere, or null
def sphere($o; $d):
  vsub($o; C) as $oc | vdot($oc; $d) as $b | (vdot($oc; $oc) - 1) as $c
  | ($b * $b - $c) as $disc
  | if $disc > 0 then (0 - $b - ($disc | sqrt)) as $t | (if $t > 0.001 then $t else null end)
    else null end;

# distance to the floor plane y = 0, or null
def floorhit($o; $d):
  if $d[1] < -0.001 then ((0 - $o[1]) / $d[1]) as $t | (if $t > 0.001 then $t else null end)
  else null end;

def sky($d): fmax($d[1]; 0) as $k | [0.9 - 0.5 * $k, 0.95 - 0.35 * $k, 1];
def fog($c; $t): ($t / ($t + 25)) as $f | vadd(vmul($c; 1 - $f); vmul(HORIZON; $f));
def pow32($x): ($x * $x) as $a | ($a * $a) as $b | ($b * $b) as $c | ($c * $c) as $e | $e * $e;

def trace($o; $d; $depth):
  sphere($o; $d) as $ts | floorhit($o; $d) as $tf
  | if $ts != null and ($tf == null or $ts < $tf) then
      vadd($o; vmul($d; $ts)) as $p | vsub($p; C) as $n
      | vsub($d; vmul($n; 2 * vdot($d; $n))) as $r
      | fmax(vdot($n; L); 0) as $diff
      | pow32(fmax(vdot($r; L); 0)) as $s
      | vadd(vmul([0.05, 0.55, 0.1]; 0.15 + 0.85 * $diff); [$s, $s, $s]) as $col
      | (if $depth > 0 then vadd(vmul($col; 0.75); vmul(trace($p; $r; $depth - 1); 0.25)) else $col end)
      | fog(.; $ts)
    elif $tf != null then
      vadd($o; vmul($d; $tf)) as $p
      | (($p[0] | floor) + ($p[2] | floor)) as $k
      | ($k - 2 * (($k / 2) | floor)) as $odd
      | (if $odd == 1 then [0.85, 0.2, 0.15] else [0.9, 0.9, 0.85] end) as $base
      | (if sphere($p; L) != null then 0.35 else 1 end) as $shade
      | vmul($base; (0.25 + 0.75 * L[1]) * $shade) as $col
      | (if $depth > 0 then vadd(vmul($col; 0.8); vmul(trace($p; [$d[0], 0 - $d[1], $d[2]]; $depth - 1); 0.2)) else $col end)
      | fog(.; $tf)
    else sky($d) end;

def pixel($x; $y):
  ((2 * ($x + 0.5) / W - 1) * W / H) as $u
  | (1 - 2 * ($y + 0.5) / H) as $v
  | trace([0, 1.2, -1.5]; vnorm([$u, $v - 0.1, 1.6]); 2)
  | map(if . < 0 then 0 elif . > 1 then 1 else . end | sqrt * 255 + 0.5 | floor);

"P3", "\(W) \(H)", "255",
(range(H) as $y | [range(W) as $x | pixel($x; $y)[]] | map(tostring) | join(" "))
