# polyglot-sh-zip

A file that is a POSIX shell script and a zip archive at the same time.

`sh` reads the top of the file, prints a line, and exits before it reaches the binary part. `unzip` ignores everything before the zip's central directory and reads the archive from the end. Both tools see a valid file.

## Run it

    sh hack/build.sh                    # builds hack/polyglot.sh
    sh hack/polyglot.sh                 # prints one line and exits 0
    sh hack/polyglot.sh extract out     # unpacks the zip into ./out
    unzip -l hack/polyglot.sh           # lists the zip contents
    sh hack/check.sh                    # runs the tests

## How it works

`head.sh` is a short shell script. Its last line is `exit 0`, so `sh` never parses further. The payload is a zip made from `payload/` and appended after the script. Zip readers find the end-of-central-directory record at the end of the file and use offsets from there, so the leading script bytes do not matter to them. The script's `extract` branch calls `unzip` on `$0`, which is the file itself.

`check.sh` builds the file and then checks six things: the first line is the shell shebang, a zip local header (`PK\x03\x04`) appears after the script, `sh` exits 0, `sh` prints its message, `unzip -l` lists the payload, and extraction gives back the original bytes. It also deletes the `exit 0` line from a copy and checks that the copy behaves differently, so a broken exit is caught.

## License

MIT
