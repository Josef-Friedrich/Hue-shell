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
$CP uninstall.sh $DIR_BIN/hue-uninstall

# By Hue-shell generated run files that should "survive" reboot.
mkdir -p $DIR_RUN_PERM
chmod 777 $DIR_RUN_PERM
touch $FILE_RANDOM_SEED
chmod 666 $FILE_RANDOM_SEED

# doc
mkdir -p $DIR_DOC
$CP doc/* $DIR_DOC

##
# Service
##

# OpenWrt
if [ -f /etc/openwrt_version ]; then
	echo "Installing init.d services ..."
	_install() {
		$CP service/openwrt.initd/$1 /etc/init.d/hue-$1
		/etc/init.d/hue-$1 enable
	}
	_install load-default
	_install detect-lights
	_install detect-bridge

# systemd
elif command -v systemctl > /dev/null 2>&1; then
	echo "Installing systemd services ..."
	_install() {
		$CP service/systemd/$1 /lib/systemd/system/hue-$1.service
		systemctl enable /lib/systemd/system/hue-$1.service
	}
	_install load-default
	_install detect-lights
	_install detect-bridge

# SysVinit
elif [ -d '/etc/init.d' ]; then
	echo "Installing SysVinit services ..."
	_install() {
		$CP service/SysVinit/$1 /etc/init.d/$1
	}
	_install load-default
fi

# triggerhappy
if [ -d /etc/triggerhappy/triggers.d ]; then
	$CP triggerhappy/hue-shell.conf /etc/triggerhappy/triggers.d/
fi

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
