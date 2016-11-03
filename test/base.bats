#!/usr/bin/env bats

# setup() {
# 	sudo ./install.sh uninstall -y > /dev/null 2>&1
# 	sudo ./install.sh install --test 1 > /dev/null 2>&1
# }

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
