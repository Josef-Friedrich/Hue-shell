#!/usr/bin/env bats

setup() {
	sudo ./install.sh install > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh uninstall -y > /dev/null 2>&1
}

@test "Installation: bin" {
	# lib
	run test -f /usr/lib/hue-shell/base.sh
	[ "${status}" -eq 0 ]
	# bin
	run test -f /usr/bin/hue
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/huecolor-basic
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/huecolor-recipe
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/hueload-default
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/hueload-random
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/hueload-scene
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/huescene-breath
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/huescene-pendulum
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/huescene-sequence
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/hueservice-detect-bridge
	[ "${status}" -eq 0 ]
	run test -f /usr/bin/hueservice-detect-lights
	[ "${status}" -eq 0 ]
	# install.sh -> hue-manager
	run test -f /usr/bin/hue-manager
	[ "${status}" -eq 0 ]
	# conf
	run test -f /etc/hue-shell/hue-shell.conf
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/random-scenes.conf
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/scenes/default.scene
	[ "${status}" -eq 0 ]
}

@test "unittest: _hue_color_to_hue" {
	. /etc/hue-shell/hue-shell.conf

	run _hue_color_to_hue green
	[ "${output}" -eq 25500 ]
	run _hue_color_to_hue blue
	[ "${output}" -eq 46920 ]
	run _hue_color_to_hue cyan
	[ "${output}" -eq 56100 ]
	run _hue_color_to_hue
	[ "${output}" -eq 0 ]
}

@test "unittest: _hue_range" {
	. /etc/hue-shell/hue-shell.conf

	run _hue_range 1:1
	[ "${output}" -eq 1 ]
	run _hue_range 100:100
	[ "${output}" -eq 100 ]
	run _hue_range 1:100
	[ "${output}" -le 100 ]
	run _hue_range 100:1
	[ "${output}" -eq 167 ]
	SEED1=$(cat $FILE_RANDOM_SEED)
	run _hue_range 200:400
	SEED2=$(cat $FILE_RANDOM_SEED)
	[ "${SEED1}" != "${SEED2}" ]
}

@test "execute: hue" {
	run hue
	[ "${lines[1]}" = '# hue' ]
	[ "${status}" -eq 1 ]
	run hue help
	[ "${status}" -eq 0 ]
}

@test "execute: hue set 1 --on" {
	skip
	run hue set 1 --on
	[ "${status}" -eq 0 ]
}

@test "execute: hueload-scene --info" {
	run hueload-scene --info
	[ "${lines[0]}" = 'Available scenes:' ]
	[ "${lines[1]}" = ' -> default' ]
	[ "${status}" -eq 0 ]
}

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

@test "execute: hue-manager uninstall" {
	run hue-manager uninstall -y
	[ "${status}" -eq 0 ]
}
