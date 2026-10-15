# moonrot

A C program that prints the moon phase for a date. It works from the mean synodic month, so it is an estimate, not an ephemeris. Expect the phase name to be right and the percentage to be within a few points.

## Run it

    cc -Wall -Wextra -O2 -o moonrot moonrot.c -lm
    ./moonrot                 # today, UTC
    ./moonrot 2024-04-08      # any date, YYYY-MM-DD

Output is two lines: the date, the phase, the age in days, and the percent lit, then a one-line verdict for that phase.

    2024-04-08  new moon  age 29.09 d  lit 0%
    no moon tonight, the sky keeps its own counsel

Bad input prints a usage line to stderr and exits 2.

## Test

    sh check.sh

The check compiles the program with warnings on, compares known dates against their phase, and confirms bad input is rejected.

## How it works

The date is turned into a Julian day number, using the usual integer formula. The age is the difference from a reference new moon (2000-01-06 at about 18:14 UTC), taken modulo the mean synodic month of 29.530588853 days. The age picks one of eight named phases from fixed cut points. The percent lit is (1 - cos(2 pi age / month)) / 2.

The one trick is the new moon window. Ages near the end of the month belong to the next new moon, so the program checks for that wrap separately and falls back to phase 0.

MIT License
