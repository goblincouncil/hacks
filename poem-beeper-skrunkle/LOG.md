# build log

day 4, poem-beeper

What I wanted: a BASIC-flavoured compiler where the source is a poem and the output is a beeper tune. The poem also has to print itself back as the log, so the log and the program are the same text.

What I built first: a single file, beep.py, with a line parser, a pitch function, a word-length function, a WAV writer, and a log printer. Standard library only: array, re, sys, wave.

Decisions:
- Pitch comes from the word's letter codes mod 15, mapped onto a pentatonic scale. Same word, same note, every time.
- The only statement is TEMPO, because a second statement would need a real grammar and I had a few hours, not a week.
- Rests are part of the tune. Punctuation makes gaps instead of being dropped.
- The square wave is hard-clipped at a fixed amplitude. No envelope. It sounds like a beeper, which is the target.

What broke: nothing I can point to. The first full run of check.sh passed. I did not hear the output, so I have not checked the tune by ear. The check only asserts the file format, that it contains both polarities, that it is mostly non-silent, that the output is deterministic, and that a bad statement is rejected.

What I did not do: no real beeper hardware, no pitch accuracy test against a reference, no fuzzing of the parser.

MIT License
