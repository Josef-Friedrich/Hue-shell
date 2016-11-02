#!/usr/bin/env bats

setup() {
	hue-manager install --test 1 > /dev/null 2>&1
}

@test "execute: hue" {
	run hue
	[ "${lines[1]}" = '# hue' ]
	[ "${status}" -eq 1 ]
	run hue help
	[ "${status}" -eq 0 ]
}

# Test all options of hue set in order of doc

@test "execute: hue set 1 --on" {
	result=$(hue set 1 --on | jq '.on')
	[ "${result}" = 'true' ]
}

@test "execute: hue set 1 --off" {
	result=$(hue set 1 --off | jq '.on')
	[ "${result}" = 'false' ]
}

@test "execute: hue set 1 --brightness 69" {
	result=$(hue set 1 --brightness 69 | jq '.bri')
	[ "${result}" -eq 69 ]
}

@test "execute: hue set 1 --hue 69" {
	result=$(hue set 1 --hue 69 | jq '.hue')
	[ "${result}" -eq 69 ]
}

@test "execute: hue set 1 --help" {
	run hue set 1 --help
	[ "${status}" -eq 0 ]
	[ "${lines[1]}" = '# hue' ]
}

@test "execute: hue set 1 --saturation 69" {
	result=$(hue set 1 --saturation 69 | jq '.sat')
	[ "${result}" -eq 69 ]
}

@test "execute: hue set 1 -x 0.69 -y 0.96" {
	result=$(hue set 1 -x 0.69 -y 0.96 | jq '.xy')
	x=$(echo $result | jq '.[0]')
	y=$(echo $result | jq '.[1]')
	[ "${x}" = '0.69' ]
	[ "${y}" = '0.96' ]
}

@test "execute: hue set 1 --ct 169" {
	result=$(hue set 1 --ct 169 | jq '.ct')
	[ "${result}" -eq 169 ]
}

@test "execute: hue set 1 --alert none" {
	skip
	result=$(hue set 1 --alert none | jq '.alert')
	[ "${result}" = 'none' ]
}

@test "execute: hue set 1 --effect colorloop" {
	skip
	result=$(hue set 1 --effect colorloop | jq '.effect')
	[ "${result}" = 'colorloop' ]
}
