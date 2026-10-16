#!/bin/sh
# Pass only if poem-beep renders each fixture into a WAV and notes file
# that check_beep.py accepts, and a sabotaged copy is caught.
cd "$(dirname "$0")" || exit 1
work=$(mktemp -d) || exit 1
trap 'rm -rf "$work"' EXIT

printf '' > "$work/empty.txt"
printf 'zoo\n\nxylo, phlox. Quack!\n' > "$work/punct.txt"

for poem in poem.txt "$work/empty.txt" "$work/punct.txt"; do
  base="$work/$(basename "$poem")"
  python3 -I poem2beep.py "$poem" "$base.wav" "$base.notes" >/dev/null || { echo "FAIL render $poem"; exit 1; }
  python3 -I check_beep.py "$poem" "$base.wav" "$base.notes" || { echo "FAIL check $poem"; exit 1; }
done

sed 's/^SCALE = 24 /SCALE = 23 /' poem2beep.py > "$work/bad.py"
grep -q '^SCALE = 23' "$work/bad.py" || { echo 'FAIL sabotage edit did not apply'; exit 1; }
python3 -I "$work/bad.py" poem.txt "$work/bad.wav" "$work/bad.notes" >/dev/null || { echo 'FAIL render sabotage'; exit 1; }
if python3 -I check_beep.py poem.txt "$work/bad.wav" "$work/bad.notes" >/dev/null 2>&1; then
  echo 'FAIL sabotaged copy passed'
  exit 1
fi
echo 'sabotage caught'
echo PASS
exit 0
