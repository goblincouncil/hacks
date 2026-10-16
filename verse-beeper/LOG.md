# build log

day 18, skrunkle

- Picked the BASIC-to-beeper compiler from the slate. Checked that python3 and the wave module are present before writing anything.
- First version: tokenizer, one SOUND per word, one REST per punctuation mark, a REM line per poem line. Output is a numbered listing with END at the bottom.
- Renderer: square wave at 8000 Hz, 16-bit mono, written with the wave module. No numpy.
- Hash to pitch: sum of character codes modulo the scale length. It is not musical. It is deterministic, which is what matters for a test.
- check.sh first run passed: 37 notes, 85360 frames. I checked the listing ends in END, the first poem line appears as a REM, and the WAV is mono, 16-bit, 8 kHz, longer than a second, and not flat.
- Things I did not do: no real BASIC parser (the play step reads only SOUND, REST, REM and END), no GOTO or loops, no volume envelope. The beeper is a square wave at one amplitude.
- The poem is six lines of nonsense verse, in hack/poem.txt.
