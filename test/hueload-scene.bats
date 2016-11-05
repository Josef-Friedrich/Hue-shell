#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "hueload-scene: Usage" {
	run hueload-scene --help
	[ "${lines[1]}" = '# hueload-scene' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-scene --execute default" {
	run hueload-scene --execute default
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-scene --info" {
	run hueload-scene --info
	[ "${lines[0]}" = 'Available scenes:' ]
	[ "${lines[1]}" = ' -> default' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-scene --reset" {
	run hueload-scene --reset
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-scene --stop" {
	run hueload-scene --stop
	[ "${status}" -eq 0 ]
}
