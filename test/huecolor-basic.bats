#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "huecolor-basic: Usage" {
	run huecolor-basic
	[ "${status}" -eq 1 ]
	[ "${lines[1]}" = '# huecolor-basic' ]

	run huecolor-basic -h
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huecolor-basic' ]

	run huecolor-basic --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huecolor-basic' ]
}
