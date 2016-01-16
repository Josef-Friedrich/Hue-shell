#! /bin/sh

. ./config/hue-shell.conf

if cp -v README.md /tmp/hue-shell-test-cp > /dev/null 2>&1 ; then
	CP='cp -v'
else
	CP='cp'
fi

# etc
mkdir -p $DIR_CONF
if [ -f $DIR_CONF/hue-shell.conf ]; then
        $CP -f $DIR_CONF/hue-shell.conf $DIR_CONF/hue-shell.conf.bak
fi
$CP -rf config/* $DIR_CONF

# lib
mkdir -p $DIR_LIB
$CP base.sh $DIR_LIB

# bin
$CP bin/hue* $DIR_BIN

# By Hue-shell generated run files that should "survive" reboot.
mkdir -p $DIR_RUN_PERM
chmod 777 $DIR_RUN_PERM
CONF_FILES="$DIR_RUN_PERM/daemon.pid $DIR_RUN_PERM/hue-shell.pids $DIR_RUN_PERM/hue-shell-random.seed $CONF/all-lights"
touch $CONF_FILES
chmod 666 $CONF_FILES

# doc
mkdir -p $DIR_DOC
$CP doc/* $DIR_DOC

# /etc/init.d
if [ -d '/etc/init.d' ]; then
	$CP startup/SysVinit /etc/init.d/hue-shell
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
