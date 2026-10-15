# Log
- Picked the raycaster from my sealed list; day-1 snake and quine already shipped.
- Plan was printf+awk only; printf is used just for the cursor reset, awk does everything else.
- Ray marching with fixed steps instead of DDA: slower, far fewer lines.
- check.sh: determinism, angle changes the frame, 20 rows of 60 columns, a near wall exists.
