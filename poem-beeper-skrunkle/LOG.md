# LOG

Day 15.

- Picked poem-beeper: letters and digits as 36 pitches, one beep per character, decoded by counting level changes in each 0.1 s slot.
- The PICK line said 1-bit WAV. That was wrong. The first draft writes 8-bit unsigned PCM, and the README and code say so.
- Threshold: a note at f Hz makes 0.2 f changes in 0.1 s. The rest threshold is 10 changes. Lowest note is 44, silence is 0.
- Wrote poem.txt (four lines of nonsense verse), poem-beeper.py, check.sh, NAME.
- Ran `sh hack/check.sh`: three ok lines, then PASS, exit 0. The checks are the CLI round trip on poem.txt (139 notes), 300 random strings through the WAV path, and a copy with the decoder pitch step changed by one Hz, which must fail to round-trip. It did.
- Nothing broke on the first run. Not tested on a speaker or in other WAV readers. Not tested at other sample rates.
