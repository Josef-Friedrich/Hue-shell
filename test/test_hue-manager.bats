#!/usr/bin/env bats

@test "execute: hue-manager" {
	run hue-manager
	[ "${lines[1]}" = '# hue-manager' ]
	[ "${status}" -eq 1 ]
}

@test "execute: hue-manager help" {
	run hue-manager help
	[ "${lines[1]}" = '# hue-manager' ]
	[ "${status}" -eq 0 ]
}

@test "execute: hue-manager install" {
	run hue-manager install
	[ "${status}" -eq 0 ]
}

@test "execute: hue-manager reinstall" {
	run hue-manager reinstall
	[ "${status}" -eq 0 ]
}

@test "execute: hue-manager upgrade" {
	run hue-manager upgrade
	[ "${status}" -eq 0 ]
}

@test "execute: hue-manager upgrde (wrong option)" {
	run hue-manager upgrde
	[ "${status}" -eq 1 ]
}

@test "execute: hue-manager uninstall" {
	run hue-manager uninstall -y
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/hue
	[ "${status}" -eq 1 ]
	./install.sh install
}
