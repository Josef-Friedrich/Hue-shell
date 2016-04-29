#! /bin/sh

. /etc/hue-shell/hue-shell.conf

echo 'Uninstall hue-shell? (y|n): '

read COMFIRMATION

if [ ! "$COMFIRMATION" = 'y' ]; then
	exit 1
fi

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

# OpenWrt
if [ -f /etc/openwrt_version ]; then
	_disable() {
		/etc/init.d/hue-$1 disable
	}
	_disable load-default
	_disable detect-lights
	_disable detect-bridge

elif command -v systemctl > /dev/null 2>&1; then
	echo "Uninstall systemd services ..."
	_disable() {
		systemctl disable hue-$1.service
	}
	_disable load-default
	_disable detect-lights
	_disable detect-bridge
	rm -f /lib/systemd/system/hue*
fi

$RM -f /etc/init.d/hue-*

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
