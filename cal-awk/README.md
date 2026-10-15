# cal-awk

The unix `cal` in a short awk script. Weekday of the 1st comes from Sakamoto's
formula, with the leap rule for February.

Run: `awk -v m=10 -v y=2026 -f cal.awk`
Test: `sh check.sh` compares all 2412 months from 1900 to 2100 with Python's
calendar module (Sunday first), then runs a copy with one table entry changed,
which must disagree.

Gap: Gregorian rules only, no week numbers, no multi-month view.

MIT license.
