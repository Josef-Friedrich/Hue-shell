#! /bin/sh

INSTALL='/usr'
ETC='/etc/hue-shell'
CONF="$HOME/.config/hue-shell"
DOC='/usr/share/doc/hue-shell'

if cp -v README.md /tmp/hue-shell-test-cp > /dev/null 2>&1 ; then
	CP='cp -v'
else
	CP='cp'
fi

# etc
mkdir -p $ETC
if [ -f $ETC/hue-shell.conf ]; then
        $CP -f $ETC/hue-shell.conf $ETC/hue-shell.conf.bak
fi
$CP -rf config/* $ETC

# lib
mkdir -p $INSTALL/lib/hue-shell
$CP base.sh $INSTALL/lib/hue-shell

# bin
$CP bin/hue* $INSTALL/bin

# By Hue-shell generated run files that should "survive" reboot.
mkdir -p $CONF
CONF_FILES="$CONF/daemon.pid $CONF/hue-shell.pids $CONF/hue-shell-random.seed $CONF/all-lights"
touch $CONF_FILES
chmod 666 $CONF_FILES

# doc
mkdir -p $DOC
$CP doc/* $DOC

# /etc/init.d
if [ -d '/etc/init.d' ]; then
	$CP startup/SysVinit /etc/init.d/hue-shell
	$CP startup/hue-detect-online-lights /etc/init.d/
fi

# systemd
if [ -d '/etc/systemd/system' ]; then
	$CP startup/systemd /etc/systemd/system/hue-shell.service
fi

# triggerhappy
if [ -d /etc/triggerhappy/triggers.d ]; then
	$CP triggerhappy/hue-shell.conf /etc/triggerhappy/triggers.d/
fi

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
