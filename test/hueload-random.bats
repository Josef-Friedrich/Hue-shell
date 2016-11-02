#!/usr/bin/env bats

@test "execute: hueload-random" {
	run hueload-random
	[ "${output: -1}" != '&' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-random --detached" {
	run hueload-random --detached
	[ "${output: -1}" = '&' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-random --help" {
	run hueload-random --help
	[ "${lines[1]}" = '# hueload-random' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-random --list" {
	run hueload-random --list
	[ "${lines[0]}" = 'huescene-sequence -H 4000,12750,6000,14500 -s 3 -t 1 -b 255' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-random --show" {
	run hueload-random --show
	[ "${lines[0]}" = '# Put each scene in one line.' ]
	[ "${status}" -eq 0 ]
}
