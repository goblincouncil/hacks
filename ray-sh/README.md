# ray-sh

A Doom-style raycaster in one shell script. awk casts 60 rays per frame through an 11x16 maze and draws wall slices as ASCII, shaded by distance.

Run: `sh ray.sh` (one frame), `sh ray.sh X Y ANGLE` (e.g. `sh ray.sh 1.5 1.5 90`), `sh ray.sh walk` (scripted turn).

How: each column steps a ray in 0.02 increments until it hits a '1' in the map, corrects fisheye with cos, and sets slice height to 20/distance. Characters # % + . get fainter with range.

MIT license.
