# specter

A picture hidden in a sound. `specter.py` writes a 4.8 second WAV that sounds
like a chord of whistles. Open it in any spectrogram viewer (Audacity,
Sonic Visualiser, a phone app) and you see a shaded ball next to the word
SPECTER. The same script can also listen to the WAV and print the picture back
as ASCII art, so you do not need a viewer to see it.

## Run it

    python3 specter.py paint out.wav          # write the sound
    python3 specter.py read out.wav           # print the picture heard in it
    python3 specter.py read out.wav out.pgm   # same, and save a grey image
    python3 specter.py picture                # the picture as painted, no sound
    sh check.sh                               # the test

Python 3 standard library only. No numpy, no FFT library.

## How it works

The picture is 96 columns by 32 rows. Each column becomes 50 ms of sound. Each
row is one sine tone: the top row is 3600 Hz, the bottom row 500 Hz, 100 Hz
apart. A pixel's brightness is that tone's loudness during that column. Add up
all the lit tones in a column and you have the samples.

The ball is drawn by sphere tracing: one ray per pixel walks forward by the
distance to the sphere until it touches it, then the surface normal gives a
diffuse term from a light at the upper left and a small specular highlight.
The letters come from a 3x5 bitmap font, scaled up.

Reading it back uses a Goertzel filter, which measures the strength of one
frequency in a block of samples. specter runs one per pixel: 32 rows times 96
columns.

The one trick: the sample rate is 8000 Hz and a column is 400 samples, so the
analysis bins are 20 Hz wide, and every tone is an exact multiple of 20 Hz.
Each tone then completes a whole number of cycles inside every column, so the
tones do not leak into each other's bins and the picture comes back almost
exactly (largest pixel error about 0.0002 out of 1). The phase also stays
continuous across columns because every sine is computed from the global
sample index, which keeps the clicks down.

## What check.sh proves

- painting twice gives byte-identical WAVs
- the ASCII picture read back from the WAV is identical to the painted one
- the WAV is 16-bit mono 8000 Hz, the right length, audible and not clipping
- every pixel survives within 0.01
- the ball has at least 8 shades and the title is there
- silence reads as a blank picture
- a plain 2000 Hz tone lights exactly one row, the right one

## Limits

The image size and font are fixed (only the letters of SPECTER exist). The
reader expects exactly the format the painter writes; a recording made with a
microphone would need a looser reader. It sounds like a dentist's drill
playing an organ.

MIT License. Copyright (c) 2026 goblincouncil.
