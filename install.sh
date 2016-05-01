#! /bin/sh

_download() {
	cd /tmp
	curl -kL -o Hue-shell.tar.gz https://github.com/Josef-Friedrich/Hue-shell/archive/master.tar.gz
	tar -xzvf Hue-shell.tar.gz
	cd Hue-shell-master
}

_install_base() {
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

	# log
	touch $FILE_LOG
	chmod 666 $FILE_LOG
}

_install_services() {
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
}

_install_triggerhappy() {
	# triggerhappy
	if [ -d /etc/triggerhappy/triggers.d ]; then
		$CP triggerhappy/hue-shell.conf /etc/triggerhappy/triggers.d/
	fi
}

_change_settings() {
	_replace() {
		sed -i "s;$1;$2;" /etc/hue-shell/hue-shell.conf
	}
	IP="192.168.2.31"
	USERNAME="joseffriedrich"
	ALL_LIGHTS="1,2,3,4,5,6,7,8,9"
	DEBUG=2
	LOG=2
	_replace 'IP="192.168.1.2"' "IP=\"$IP\""
	_replace 'USERNAME="yourusername"' "USERNAME=\"$USERNAME\""
	_replace 'ALL_LIGHTS="1,2,3"' "ALL_LIGHTS=\"$ALL_LIGHTS\""
	_replace 'DEBUG=0' "DEBUG=$DEBUG"
	_replace 'LOG=0' "LOG=$LOG"
}

_cleanup() {
	rm -rf /tmp/Hue-shell-master
	rm -f /tmp/Hue-shell.tar.gz
}

_uninstall() {
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
}


# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
