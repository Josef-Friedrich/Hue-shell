#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "huecolor-recipe: Usage" {
	run huecolor-recipe
	[ "${status}" -eq 1 ]
	[ "${lines[1]}" = '# huecolor-recipe' ]

	run huecolor-recipe -h
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huecolor-recipe' ]

	run huecolor-recipe --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# huecolor-recipe' ]
}
