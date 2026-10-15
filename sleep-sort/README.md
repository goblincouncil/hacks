# sleep sort

A sort that works by waiting. Give it non-negative integers and it starts one background timer per number. Each timer sleeps for the number's value, then prints it. Small numbers wake first, so the output comes out sorted.

## Run it

    sh sleepsort.sh 5 3 9 1 0 12 7 3
    printf '5\n3\n9\n1\n' | sh sleepsort.sh

One unit is 0.1 seconds by default. Change it with `SLEEPSORT_UNIT`:

    SLEEPSORT_UNIT=0.5 sh sleepsort.sh 4 2 8

Bad input (anything that is not a non-negative integer) is refused with exit status 2.

## Test it

    sh check.sh

The check sorts shuffled input, duplicates, zero, and reversed stdin, rejects bad input, and runs a broken copy that prints in input order to confirm the check catches it.

## How it works

Each number gets a subshell that runs `sleep` for `n * unit` seconds and then echoes `n`. The parent waits for all of them. The sleep time is computed with awk so decimal units work. Values that are very close can swap because timing depends on the scheduler, so keep the unit large enough that the timers are well apart.

MIT License
