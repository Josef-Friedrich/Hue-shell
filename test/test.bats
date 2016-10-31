#!/usr/bin/env bats

setup() {
  sudo ./install.sh install
}

teardown() {
  sudo ./install.sh uninstall -y
}

@test "color to hue" {
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
