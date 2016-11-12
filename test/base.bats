#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "unittest: _hue_color" {
	. /etc/hue-shell/hue-shell.conf

	run _hue_color alice-blue
	[ "${output}" = '-x 0.3088 -y 0.3212' ]
	run _hue_color alice-blue A
	[ "${output}" = '-x 0.3088 -y 0.3212' ]
	run _hue_color alice-blue B
	[ "${output}" = '-x 0.3092 -y 0.321' ]
	run _hue_color alice-blue C
	[ "${output}" = '-x 0.3088 -y 0.3212' ]
	run _hue_color
	[ "${output}" = '' ]
}

@test "unittest: _hue_range" {
	. /etc/hue-shell/hue-shell.conf

	run _hue_range 1:1
	[ "${output}" -eq 1 ]
	run _hue_range 100:100
	[ "${output}" -eq 100 ]
	run _hue_range 1:100
	[ "${output}" -le 100 ]
	SEED1=$(cat $FILE_RANDOM_SEED)
	run _hue_range 200:400
	SEED2=$(cat $FILE_RANDOM_SEED)
	[ "${SEED1}" != "${SEED2}" ]
}

@test "unittest: _hue_get_lights_reachable" {
	. /etc/hue-shell/hue-shell.conf
	result=$(_hue_get_lights_reachable)
	[ "${result}" = '1,2,3' ]
}

@test "unittest: _hue_get_on" {
	. /etc/hue-shell/hue-shell.conf
	result=$(_hue_get_on test/json/get_lightsNormalized.json)
	[ "${result}" = '2' ]
}

@test "unittest: _hue_log" {
	. /etc/hue-shell/hue-shell.conf
	_hue_log 1 'Log level 1'
	run test -f $FILE_LOG
	[ "${status}" -eq 0 ]
	run tail -n 1 $FILE_LOG
	[ "${output}" = ''  ]

	LOG=1
	_hue_log 1 'Log level 1'
	run tail -n 1 $FILE_LOG
	output=$(echo $output | sed 's/.*\] //')
	[ "${output}" = 'Log level 1'  ]

	_hue_log 2 'no logging'
	run tail -n 1 $FILE_LOG
	output=$(echo $output | sed 's/.*\] //')
	[ "${output}" = 'Log level 1'  ]

}
