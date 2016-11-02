#!/usr/bin/env bats

@test "unittest: _hue_color" {
	. /etc/hue-shell/hue-shell.conf

	run _hue_color green
	[ "${output}" -eq 25500 ]
	run _hue_color blue
	[ "${output}" -eq 46920 ]
	run _hue_color cyan
	[ "${output}" -eq 56100 ]
	run _hue_color
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
