#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "hueload-default: Usage" {
	run hueload-default
	[ "${status}" -eq 0 ]

	run hueload-default -h
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# hueload-default' ]

	run hueload-default --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# hueload-default' ]
}
