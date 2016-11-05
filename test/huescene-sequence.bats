#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "huescene-sequence: Usage" {
	run huescene-sequence -h
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huescene-sequence' ]

	run huescene-sequence --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huescene-sequence' ]
}
