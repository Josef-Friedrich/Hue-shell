#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "huescene-pendulum: Usage" {
	run huescene-pendulum -h
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huescene-pendulum' ]

	run huescene-pendulum --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huescene-pendulum' ]
}
