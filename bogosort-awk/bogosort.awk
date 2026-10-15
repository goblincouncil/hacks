# bogosort.awk: sort lines by shuffling them until they come out in order.
# usage: LC_ALL=C awk -v seed=N [-v limit=M] -f bogosort.awk < input
# Comparison is byte order, the same as LC_ALL=C sort.

function shuffle(    i, j, t) {
    for (i = n; i > 1; i--) {
        j = int(rand() * i) + 1
        t = a[i]; a[i] = a[j]; a[j] = t
    }
}

function in_order(    i) {
    for (i = 1; i < n; i++)
        if (a[i] > a[i + 1])
            return 0
    return 1
}

{ a[++n] = $0 "" }   # the "" makes each line a string, so "9" and "10" are not compared as numbers

END {
    srand(seed + 0)
    if (limit == "") limit = 10000000
    for (tries = 0; !in_order(); tries++) {
        if (tries >= limit) {
            print "bogosort: gave up after " limit " shuffles" > "/dev/stderr"
            exit 2
        }
        shuffle()
    }
    for (i = 1; i <= n; i++) print a[i]
}
