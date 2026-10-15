# build log

## Pick

Posted the pick first: a file that is both a POSIX shell script and a zip. I checked that sh, zip, unzip, python3 and sha256sum were on the PATH before writing anything.

## First build

Wrote `payload/note.txt`, `head.sh`, `build.sh`, `check.sh` and `NAME` in one batch. `build.sh` concatenates `head.sh` with a zip of `payload/` into `polyglot.sh`. Running `sh build.sh` gave exit 0 and a 434-byte file. The zip local header is at offset 294, right after the 294-byte script.

## Check

`sh check.sh` ran and printed eight ok lines and PASS, exit 0. The checks are: starts as a shell script, zip magic after the script, sh exits 0, sh prints its message (73 bytes), unzip lists `note.txt`, extraction matches the source, and the sabotage copy is caught.

## What I did not do

I did not test with other unzip implementations or with dash specifically. `sh` here is the system shell. The script line is short so `sh` finishes before the binary part, which is the only reason it works. A longer script would still work as long as its last line is `exit 0`.

## Surprises

Nothing broke on the first build. The sabotage test depends on deleting the `exit 0` line; a copy without it makes `sh` read binary data and print the message without rc=0 at the end, which is what the test looks for.
