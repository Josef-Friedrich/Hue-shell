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

@test "execute: hue-manager install --all-lights 1,2,3,4,5,6,7,8,9" {
	run hue-manager install --all-lights 1,2,3,4,5,6,7,8,9
	. /etc/hue-shell/hue-shell.conf
	[ "${ALL_LIGHTS}" = '1,2,3,4,5,6,7,8,9' ]
}

@test "execute: hue-manager install --debug 1" {
	run hue-manager install --debug 1
	. /etc/hue-shell/hue-shell.conf
	[ "${DEBUG}" -eq 1 ]
}

@test "execute: hue-manager install --ip 10.69.69.69" {
	run hue-manager install --ip 10.69.69.69
	. /etc/hue-shell/hue-shell.conf
	[ "${IP}" = '10.69.69.69' ]
}

@test "execute: hue-manager install --log 1" {
	run hue-manager install --log 1
	. /etc/hue-shell/hue-shell.conf
	[ "${LOG}" -eq 1  ]
}

@test "execute: hue-manager install --username joseffriedrich" {
	run hue-manager install --username joseffriedrich
	. /etc/hue-shell/hue-shell.conf
	[ "${USERNAME}" = 'joseffriedrich' ]
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
