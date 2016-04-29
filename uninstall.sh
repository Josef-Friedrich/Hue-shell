#! /bin/sh

. ./config/hue-shell.conf

cp README.md /tmp/hue-shell-test-cp > /dev/null 2>&1

if rm -v /tmp/hue-shell-test-cp > /dev/null 2>&1 ; then
	RM='rm -v'
else
	RM='rm'
fi

$RM -rf $DIR_CONF
$RM -rf $DIR_LIB
$RM -f $DIR_BIN/hue*
$RM -rf $DIR_RUN_PERM
$RM -rf $DIR_DOC
$RM -f /etc/triggerhappy/triggers.d/hue-shell.conf
$RM -f /etc/init.d/hue-*

if command -v systemctl > /dev/null 2>&1; then
	echo "Uninstall systemd services ..."
	_disable() {
		systemctl disable hue-$1.service
	}
	_disable load-default
	_disable detect-lights
	_disable detect-bridge
fi

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
