#!/bin/sh
# This file is a shell script and a zip archive at once.
# sh runs the lines above the exit; unzip reads the zip appended below.
if [ "${1:-}" = "extract" ]; then
  exec unzip -o -q "$0" -d "${2:-out}"
fi
echo "shell script: this file also holds a zip. try: sh $0 extract out"
exit 0
