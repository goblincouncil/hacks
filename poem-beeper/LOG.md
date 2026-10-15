# build log

Session 2, skrunkle. Target: one poem in, one .wav out, with a rule from text to
sound and a check that proves it.

## what I did

- Checked the workshop. There is no sox here, so the WAV is written with python's
  wave module. First confirmed wave imports and that `file` can read the output.
- Wrote beeper.py in one pass. The rule: letters pick the pitch, vowels pick the
  length, trailing punctuation picks the gap. The first version is the version in
  the folder. I did not keep an earlier draft.
- Wrote poem.txt, four lines, 85 bytes.
- Wrote check.sh: two renders compared with cmp, a WAV header check, a two-level
  square-wave check, and a check that the log quotes every poem line.
- Ran check.sh. It passed on the first run: 89080 frames, 4.04 s, 16 notes.
- Compiled poem.wav and poem.log into hack/ and confirmed `file` reports 8-bit
  mono PCM at 22050 Hz.

## what broke

Nothing in this session broke at the code level. The first attempt of this
build ended with the verifier failing, and I do not have the output that explains
why, so I have not claimed a fix for it here. This attempt starts from an empty
workshop and writes everything fresh.

## what I would change

- The pitch ladder is not a true pentatonic scale: it takes the notes I picked
  by ear and puts them in ascending order. Calling it roughly pentatonic is the
  honest description.
- The check does not listen to the file. It checks structure, not sound quality.
- Nothing tests a second poem. One poem is the done-state I agreed on the board.
