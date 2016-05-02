#! /bin/sh

# sh -c "OPT=install; $(curl -fsSkL http://raw.github.com/Josef-Friedrich/Hue-shell/master/install.sh)"

# To restore values on upgrade
# sh -c "OPT=install;R_IP=192.168.2.31;R_USERNAME=joseffriedrich;R_ALL_LIGHTS=1,2,3,4,5,6,7,8,9;R_DEBUG=0;R_LOG=0; $(curl -fsSkL http://raw.github.com/Josef-Friedrich/Hue-shell/master/install.sh)"

if [ -f /etc/hue-shell/hue-shell.conf ]; then
	. /etc/hue-shell/hue-shell.conf
elif [ -f ./config/hue-shell.conf ]; then
	. ./config/hue-shell.conf
else
	NO_CONFIG=1
fi

if [ -z "$OPT" ]; then
	OPT=$1
fi

if type sudo > /dev/null ; then
	_sudo() {
		sudo $@
	}
else
	_sudo() {
		$@
	}
fi

_cp() {
	echo "install: $@"
	_sudo cp $@
}

_mkdir() {
	echo "mkdir: $@"
	_sudo mkdir $@
}

_rm() {
	echo "uninstall: $@"
	_sudo rm -rf $@
}

_usage() {
	if type _hue_usage > /dev/null 2>&1; then
		_hue_usage
	else
		echo "Usage: $(basename $0) (install|upgrade|uninstall)"
	fi
}

_download() {
	cd /tmp
	curl -fsSkL -o Hue-shell.tar.gz http://github.com/Josef-Friedrich/Hue-shell/archive/master.tar.gz
	tar -xzvf Hue-shell.tar.gz
	cd Hue-shell-master
}

_install_base() {
	# etc
	_sudo mkdir -p $DIR_CONF
	if [ -f $DIR_CONF/hue-shell.conf ]; then
		_cp -f $DIR_CONF/hue-shell.conf $DIR_CONF/hue-shell.conf.bak
	fi
	_cp -rf config/* $DIR_CONF

	# lib
	_mkdir -p $DIR_LIB
	_cp base.sh $DIR_LIB

	# bin
	_cp bin/hue* $DIR_BIN
	_cp install.sh $DIR_BIN/hue-manager

	# By Hue-shell generated run files that should "survive" reboot.
	_mkdir -p $DIR_RUN_PERM
	_sudo chmod 777 $DIR_RUN_PERM
	_sudo touch $FILE_RANDOM_SEED
	_sudo chmod 666 $FILE_RANDOM_SEED

	# doc
	_mkdir -p $DIR_DOC
	_cp doc/* $DIR_DOC

	# log
	_sudo touch $FILE_LOG
	_sudo chmod 666 $FILE_LOG
}

_install_services() {
	# OpenWrt
	if [ -f /etc/openwrt_version ]; then
		echo "Installing init.d services ..."
		_install() {
			_cp service/openwrt.initd/$1 /etc/init.d/hue-$1
			/etc/init.d/hue-$1 enable
		}
		_install load-default
		_install detect-lights
		_install detect-bridge

	# systemd
	elif command -v systemctl > /dev/null 2>&1; then
		echo "Installing systemd services ..."
		_install() {
			_cp service/systemd/$1 /lib/systemd/system/hue-$1.service
			_sudo systemctl enable /lib/systemd/system/hue-$1.service
		}
		_install load-default
		_install detect-lights
		_install detect-bridge

	# SysVinit
	elif [ -d '/etc/init.d' ]; then
		echo "Installing SysVinit services ..."
		_install() {
			_cp service/SysVinit/$1 /etc/init.d/$1
		}
		_install load-default
	fi
}

_install_triggerhappy() {
	if [ -d /etc/triggerhappy/triggers.d ]; then
		_cp triggerhappy/hue-shell.conf /etc/triggerhappy/triggers.d/
	fi
}

_cleanup() {
	_rm /tmp/Hue-shell-master
	_rm /tmp/Hue-shell.tar.gz
}

_install() {
	if [ ! -f ./bin/hue ]; then
		_download
	fi
	_install_base
	_install_services
	_install_triggerhappy
	_cleanup
}

_upgrade() {
	if [ ! -f ./bin/hue ]; then
		_download
	fi
	_install_base
	_install_services
	_install_triggerhappy
	_cleanup
}

_restore_configuration() {
	_replace() {
		_sudo sed -i "s;$1;$2;" /etc/hue-shell/hue-shell.conf
	}

	if [ -n "$R_IP" ]; then _replace 'IP="192.168.1.2"' "IP=\"$R_IP\"" ; fi
	if [ -n "$R_USERNAME" ]; then _replace 'USERNAME="yourusername"' "USERNAME=\"$R_USERNAME\"" ; fi
	if [ -n "$R_ALL_LIGHTS" ]; then _replace 'ALL_LIGHTS="1,2,3"' "ALL_LIGHTS=\"$R_ALL_LIGHTS\"" ; fi
	if [ -n "$R_DEBUG" ]; then _replace 'DEBUG=0' "DEBUG=$R_DEBUG" ; fi
	if [ -n "$R_LOG" ]; then _replace 'LOG=0' "LOG=$R_LOG" ; fi
}

_uninstall() {
	echo 'Uninstall hue-shell? (y|n): '

	read COMFIRMATION

	if [ ! "$COMFIRMATION" = 'y' ]; then
		exit 1
	fi

	_rm $DIR_CONF
	_rm $DIR_LIB
	_rm $DIR_BIN/hue*
	_rm $DIR_RUN_PERM
	_rm $DIR_DOC
	_rm /etc/triggerhappy/triggers.d/hue-shell.conf

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
			_sudo systemctl disable hue-$1.service
		}
		_disable load-default
		_disable detect-lights
		_disable detect-bridge
		rm -f /lib/systemd/system/hue*
	fi

	_rm /etc/init.d/hue-*
}

case "$OPT" in

	install)
		_install
		_restore_configuration
		break
		;;
	upgrade)
		_upgrade
		_restore_configuration
		break
		;;

	uninstall)
		_uninstall
		break
		;;

	*)
		_usage
		break
		;;

esac

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
