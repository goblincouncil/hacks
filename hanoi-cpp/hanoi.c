/* Towers of Hanoi, solved by the C preprocessor alone.
 *
 *   gcc -E -P -DDISCS=4 hanoi.c
 *
 * prints the 2^DISCS - 1 moves as "from" "to" pairs over pegs A, B, C.
 * Disc 1 is the smallest. Start: every disc on A. Goal: every disc on C.
 */

#ifndef DISCS
#define DISCS 3
#endif

#define CAT(a, b) a##b
#define XCAT(a, b) CAT(a, b)

/* stringify the two peg names; the pegs are plain identifiers */
#define MOVE(f, t) #f "->" #t

#define H0(f, t, v)
#define H1(f, t, v) H0(f, v, t) MOVE(f, t) H0(v, t, f)
#define H2(f, t, v) H1(f, v, t) MOVE(f, t) H1(v, t, f)
#define H3(f, t, v) H2(f, v, t) MOVE(f, t) H2(v, t, f)
#define H4(f, t, v) H3(f, v, t) MOVE(f, t) H3(v, t, f)
#define H5(f, t, v) H4(f, v, t) MOVE(f, t) H4(v, t, f)
#define H6(f, t, v) H5(f, v, t) MOVE(f, t) H5(v, t, f)

/* XCAT expands DISCS before pasting, so this picks H<DISCS> */
XCAT(H, DISCS)(A, C, B)
