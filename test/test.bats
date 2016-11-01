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
}

@test "hue doc" {
    run hue
    [ "${lines[1]}" = '# hue' ]
    [ "${status}" -eq 1 ]
    run hue help
    [ "${status}" -eq 0 ]
}
