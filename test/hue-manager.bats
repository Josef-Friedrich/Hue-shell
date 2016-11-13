#!/usr/bin/env bats

setup() {
	sudo ./install.sh install --test 1 > /dev/null 2>&1
}

teardown() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "File status: install" {
	if [ $(uname) = 'Darwin' ]; then
		PREFIX=/usr/local
	else
		PREFIX=/usr
	fi
	# bins
	# install.sh -> hue-manager
	run test -f ${PREFIX}/bin/hue-manager
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hue
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/huecolor-basic
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/huecolor-recipe
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hueload-default
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hueload-random
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hueload-scene
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/huescene-breath
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/huescene-pendulum
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/huescene-sequence
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hueservice-detect-bridge
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hueservice-detect-lights
	[ "${status}" -eq 0 ]

	# conf
	run test -d /etc/hue-shell
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/hue-shell.conf
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/random-scenes.conf
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/scenes/default.scene
	[ "${status}" -eq 0 ]

	# doc
	run test -d ${PREFIX}/share/doc/hue-shell
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hue-manager.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hue.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/huecolor-basic.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/huecolor-recipe.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hueload-default.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hueload-random.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hueload-scene.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/huescene-breath.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/huescene-pendulum.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/huescene-sequence.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hueservice-detect-bridge.txt
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/share/doc/hue-shell/hueservice-detect-lights.txt
	[ "${status}" -eq 0 ]

	# lib
	run test -d ${PREFIX}/lib/hue-shell
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/lib/hue-shell/base.sh
	[ "${status}" -eq 0 ]

	# log
	run test -f /var/log/hue-shell.log
	[ "${status}" -eq 0 ]

	# run
	run test -d $HOME/.config/hue-shell
	[ "${status}" -eq 0 ]
	run test -f $HOME/.config/hue-shell/hue-shell-random-seed
	[ "${status}" -eq 0 ]
	run test -f $HOME/.config/hue-shell/hue-shell.pids
	[ "${status}" -eq 0 ]
}

@test "File status: uninstall" {
	if [ $(uname) = 'Darwin' ]; then
		PREFIX=/usr/local
	else
		PREFIX=/usr
	fi
	./install.sh uninstall -y

	# bins
	# install.sh -> hue-manager
	run test -f ${PREFIX}/bin/hue-manager
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/hue
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/huecolor-basic
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/huecolor-recipe
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/hueload-default
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/hueload-random
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/hueload-scene
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/huescene-breath
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/huescene-pendulum
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/huescene-sequence
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/hueservice-detect-bridge
	[ "${status}" -eq 1 ]
	run test -f ${PREFIX}/bin/hueservice-detect-lights
	[ "${status}" -eq 1 ]

	# conf
	run test -d /etc/hue-shell
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/hue-shell.conf
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/random-scenes.conf
	[ "${status}" -eq 0 ]
	run test -f /etc/hue-shell/scenes/default.scene
	[ "${status}" -eq 0 ]

	./install.sh install --test 1
}

@test "File status: purge" {
	if [ $(uname) = 'Darwin' ]; then
		PREFIX=/usr/local
	else
		PREFIX=/usr
	fi
	./install.sh purge -y

	# conf
	run test -d /etc/hue-shell
	[ "${status}" -eq 1 ]
	run test -f /etc/hue-shell/hue-shell.conf
	[ "${status}" -eq 1 ]
	run test -f /etc/hue-shell/random-scenes.conf
	[ "${status}" -eq 1 ]
	run test -f /etc/hue-shell/scenes/default.scene
	[ "${status}" -eq 1 ]

	./install.sh install --test 1
}

@test "hue-manager: Usage" {
	run hue-manager
	[ "${lines[1]}" = '# hue-manager' ]
	[ "${status}" -eq 1 ]

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

@test "execute: hue-manager install --gamut A" {
	run hue-manager install --gamut A
	. /etc/hue-shell/hue-shell.conf
	[ "${GAMUT}" = 'A' ]
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

@test "execute: hue-manager install --test 1" {
	run hue-manager install --test 1
	. /etc/hue-shell/hue-shell.conf
	[ "${TEST}" -eq 1  ]
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
	[ -f /etc/hue-shell/hue-shell.conf.new ]
	[ -f /etc/hue-shell/random-scenes.conf.new ]
	[ -f /etc/hue-shell/scenes/default.scene.new ]
}

@test "execute: hue-manager upgrde (wrong option)" {
	run hue-manager upgrde
	[ "${status}" -eq 1 ]
}

@test "execute: hue-manager uninstall" {
	run hue-manager uninstall -y
	[ "${status}" -eq 0 ]
	./install.sh install --test 1
}

@test "execute: hue-manager purge" {
	run hue-manager purge -y
	[ "${status}" -eq 0 ]
	./install.sh install --test 1
}
