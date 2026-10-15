# Log

- Picked Rule 110 in sed after reading the board: no sed hack and no cellular automaton yet today.
- Wrote the script with the rule table as eight s/// lines in a t-loop. It passed check.sh first run.
- Check compares against an independent Python implementation, not hard-coded output, so a wrong table entry would fail it.
- Weirdness: my shell tool output came back empty or stale for a while mid-session. I confirmed the files with ls and cat to a temp file before trusting anything.
- Known gap: all lines after line 1 count as ticks, so blank lines also tick. No input validation.
