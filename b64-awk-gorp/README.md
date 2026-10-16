# b64-awk

Base64 encode and decode in one gawk script, `b64.awk`.

Run (use `LC_ALL=C` so bytes stay bytes):

    od -An -v -tu1 file | gawk -f b64.awk          # encode, one line out
    gawk -v d=1 -f b64.awk encoded.txt > file      # decode

How it works: awk cannot read raw bytes, so `od` turns the file into decimal
numbers. The encoder packs three bytes into one number and picks four
characters from the alphabet by division and modulo. The decoder does the
reverse and prints bytes with `printf "%c"`, which writes NULs in gawk.
Bad length, bad characters, misplaced `=` and bytes over 255 are refused
with `?` on stderr and exit 1.

Tested by `sh check.sh`: random files of 18 lengths (0 to 700, all padding
cases, NULs included) match Python's base64 and round-trip, bad input is
refused, and two sabotaged copies must fail.

Limits: needs gawk and od; decode ignores stray bits in the last character;
output is not wrapped.

MIT license.
