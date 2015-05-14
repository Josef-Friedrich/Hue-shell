#! /bin/sh

INSTALL_DIR='/usr'

cp README.md /tmp/hue-shell-test-cp > /dev/null 2>&1

if rm -v /tmp/hue-shell-test-cp > /dev/null 2>&1 ; then
	RM='rm -v'
else
	RM='rm'
fi

$RM -rf /etc/hue-shell
$RM -rf $INSTALL_DIR/lib/hue-shell
$RM -f $INSTALL_DIR/bin/hue*
$RM -f /etc/init.d/hue
$RM -rf /var/tmp/hue-shell
$RM -rf /usr/share/doc/hue-shell
$RM -f /etc/triggerhappy/triggers.d/hue.conf

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;