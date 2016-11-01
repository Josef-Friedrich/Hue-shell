#!/usr/bin/env bats

setup() {
  sudo ./install.sh install > /dev/null 2>&1
}

teardown() {
  sudo ./install.sh uninstall -y > /dev/null 2>&1
}

@test "Installation: bin" {
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
}

@test "unittest: _hue_color_to_hue" {
    PWD=$(pwd)
    . "$PWD"/base.sh

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
    skip
    PWD=$(pwd)
    . "$PWD"/base.sh

    run _hue_range 1:200
    [ "${output}" -eq 1 ]
}
