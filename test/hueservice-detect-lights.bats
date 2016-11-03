#!/usr/bin/env bats

# setup() {
# 	sudo ./install.sh uninstall -y > /dev/null 2>&1
# 	sudo ./install.sh install --test 1 > /dev/null 2>&1
# }

@test "execute: hueservice-detect-lights" {
	run hueservice-detect-lights
	[ "${lines[1]}" = '# hueservice-detect-lights' ]
	[ "${status}" -eq 1 ]
}

@test "execute: hueservice-detect-lights status" {
	run hueservice-detect-lights status
	[ "${lines[0]}" = "The service 'hueservice-detect-lights' is not running." ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueservice-detect-lights start" {
	skip
	run hueservice-detect-lights start
	[ "${lines[0]}" = "The service 'hueservice-detect-lights' is not running." ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueservice-detect-lights stop" {
	run hueservice-detect-lights stop
	[ "${lines[0]}" = "Stopping the service 'hueservice-detect-lights'." ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueservice-detect-lights --help" {
	run hueservice-detect-lights --help
	[ "${lines[1]}" = '# hueservice-detect-lights' ]
	[ "${status}" -eq 0 ]
}
