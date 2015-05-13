#! /bin/sh

INSTALL_DIR='/usr'

if cp -v README.md /tmp/hue-shell-test-cp > /dev/null 2>&1 ; then
	CP='cp -v'
else
	CP='cp'
fi

# etc
mkdir -p /etc/hue-shell
$CP -r config/* /etc/hue-shell

# lib
mkdir -p $INSTALL_DIR/lib/hue-shell
$CP base.sh $INSTALL_DIR/lib/hue-shell

# bin
$CP bin/hue* $INSTALL_DIR/bin

# run
RUN='/var/run/hue-shell'
mkdir -p $RUN
RUN_FILES="$RUN/hue-shell.pids $RUN/hue-shell-random.seed"
touch $RUN_FILES
chmod 666 $RUN_FILES

# doc
if [ -d '/usr/share/doc' ]; then
	DOC='/usr/share/doc/hue-shell'
	mkdir -p $DOC
	$CP doc/* $DOC
fi

# /etc/init.d
$CP startup/SysVinit /etc/init.d/hue

# triggerhappy
if [ -f /etc/triggerhappy/triggers.d ]; then
	$CP triggerhappy/hue.conf /etc/triggerhappy/triggers.d/
fi

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;