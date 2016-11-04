#!/usr/bin/env bats

setup() {
	sudo ./install.sh purge -y > /dev/null 2>&1
}

@test "Installation by command line paste" {
	if [ $(uname) = 'Darwin' ]; then
		PREFIX=/usr/local
	else
		PREFIX=/usr
	fi
	run test -f ${PREFIX}/bin/hue
	[ "${status}" -eq 1 ]
	cd /tmp
	run sh -c "OPT=install; $(curl -fksSkL http://raw.github.com/Josef-Friedrich/Hue-shell/master/install.sh)"
	[ "${status}" -eq 0 ]
	run test -f ${PREFIX}/bin/hue
	[ "${status}" -eq 0 ]
}
