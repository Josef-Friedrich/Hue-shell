#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "hueservice-detect-bridge: Usage" {
	run hueservice-detect-bridge -h
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# hueservice-detect-bridge' ]

	run hueservice-detect-bridge --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# hueservice-detect-bridge' ]
}
