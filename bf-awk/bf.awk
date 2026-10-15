# bf.awk: a Brainfuck interpreter in one awk file.
# usage: LC_ALL=C awk -f bf.awk program.bf < input > output
# Cells are bytes and wrap at 0 and 255. The tape grows to the right and may
# not go left of cell 0. Reading past the end of input stores 0.
# Only the eight op characters count; every other character is a comment.

function err(msg) {
	print "bf: " msg > "/dev/stderr"
	exit 2
}

BEGIN {
	RS = "^$"
	if (ARGC < 2) {
		print "usage: awk -f bf.awk program.bf < input" > "/dev/stderr"
		exit 1
	}
	path = ARGV[1]
	ARGV[1] = ""
	if ((getline src < path) < 0) {
		print "bf: cannot read " path > "/dev/stderr"
		exit 1
	}
	getline inbuf < "/dev/stdin"

	for (i = 0; i < 256; i++) ord[sprintf("%c", i)] = i

	n = 0
	for (k = 1; k <= length(src); k++) {
		c = substr(src, k, 1)
		if (index("><+-.,[]", c) > 0) code[n++] = c
	}

	sp = 0
	for (i = 0; i < n; i++) {
		if (code[i] == "[") {
			stack[sp++] = i
		} else if (code[i] == "]") {
			if (sp == 0) err("unmatched ] at op " i)
			j = stack[--sp]
			jump[i] = j
			jump[j] = i
		}
	}
	if (sp > 0) err("unmatched [ at op " stack[sp - 1])

	ip = 0; ptr = 0; pos = 1
	while (ip < n) {
		op = code[ip]
		if (op == ">") {
			ptr++
		} else if (op == "<") {
			ptr--
			if (ptr < 0) err("pointer moved left of cell 0 at op " ip)
		} else if (op == "+") {
			tape[ptr] = (tape[ptr] + 1) % 256
		} else if (op == "-") {
			tape[ptr] = (tape[ptr] + 255) % 256
		} else if (op == ".") {
			printf "%c", tape[ptr]
		} else if (op == ",") {
			if (pos <= length(inbuf)) {
				tape[ptr] = ord[substr(inbuf, pos, 1)]
				pos++
			} else {
				tape[ptr] = 0
			}
		} else if (op == "[") {
			if (tape[ptr] == 0) ip = jump[ip]
		} else if (op == "]") {
			if (tape[ptr] != 0) ip = jump[ip]
		}
		ip++
	}
	exit 0
}
