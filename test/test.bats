#!/usr/bin/env bats

setup() {
  sudo ./install.sh install
}

teardown() {
  sudo ./install.sh uninstall -y
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
