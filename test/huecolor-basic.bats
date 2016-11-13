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

@test "huecolor-basic: Some colors" {
	_test_color() {
		run huecolor-basic "$1"
		[ "${status}" -eq 0 ]
		x=$(echo ${lines[0]} | jq '.xy[0]')
		y=$(echo ${lines[0]} | jq '.xy[1]')
		[ "${x}" = "$2" ]
		[ "${y}" = "$3" ]
	}

# One dash options
	_test_color -r 0.7 0.2986
	_test_color -c 0.17 0.3403
	_test_color -g 0.214 0.709
	_test_color -w 0.3227 0.329
	_test_color -y 0.4432 0.5154

# Two dash options
	_test_color --red 0.7 0.2986
	_test_color --spring-green 0.1994 0.5864

# Wrong option
	run huecolor-basic --lol
	[ "${status}" -eq 0 ]
	result=$(echo ${lines[0]} | jq '.alert')
	echo $result > log
	[ "${result}" = '"select"' ]

}
