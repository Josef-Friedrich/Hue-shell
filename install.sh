#! /bin/sh

# sh -c "OPT=install; $(curl -fsSkL http://raw.github.com/Josef-Friedrich/Hue-shell/master/install.sh)"

# To restore values on upgrade
# sh -c "OPT=install;R_IP=192.168.2.31;R_USERNAME=joseffriedrich;R_ALL_LIGHTS=1,2,3,4,5,6,7,8,9;R_DEBUG=0;R_LOG=0; $(curl -fsSkL http://raw.github.com/Josef-Friedrich/Hue-shell/master/install.sh)"

if [ -f /etc/hue-shell/hue-shell.conf ]; then
	# shellcheck disable=SC1091
	. /etc/hue-shell/hue-shell.conf
elif [ -f ./config/hue-shell.conf ]; then
	# shellcheck disable=SC1091
	. ./config/hue-shell.conf
else
	NO_CONFIG=1
fi

if [ -z "$OPT" ]; then
	OPT=$1
fi

# shellcheck disable=SC2039
if type sudo > /dev/null ; then
	_sudo() {
		sudo "$@"
	}
else
	_sudo() {
		"$@"
	}
fi

_cp() {
	echo "install: $*"
	_sudo cp -f "$@"
}

_mkdir() {
	echo "mkdir: $*"
	_sudo mkdir -p "$@"
}

_rm() {
	echo "uninstall: $*"
	_sudo rm -rf "$@"
}

_usage() {
	if [ -f "${PREFIX}/share/doc/hue-shell/hue-manager.txt" ] ; then
		cat "${PREFIX}/share/doc/hue-shell/hue-manager.txt"
	else
		echo "Usage: $(basename "$0") (help|install|reinstall|upgrade|uninstall)"
	fi
	# shellcheck disable=SC2086
	exit $1
}

_download() {
	cd /tmp || exit
	curl -fsSkL -o Hue-shell.tar.gz http://github.com/Josef-Friedrich/Hue-shell/archive/master.tar.gz
	tar -xzvf Hue-shell.tar.gz
	cd Hue-shell-master || exit
}

_install_base() {
	# bin
	_cp bin/hue* "$DIR_BIN"
	_cp install.sh "$DIR_BIN/hue-manager"

	# conf
	_sudo mkdir -p "$DIR_CONF"
	if [ -n "$UPGRADE" ]; then
		_new_conf() {
			_cp "./config/$1" "$DIR_CONF/$1.new"
		}
		_new_conf hue-shell.conf
		_new_conf random-scenes.conf
		_new_conf scenes/default.scene
	else
		if [ -f "$DIR_CONF/hue-shell.conf" ]; then
			_cp "$DIR_CONF/hue-shell.conf" "$DIR_CONF/hue-shell.conf.bak"
		fi
		_cp -r config/* "$DIR_CONF"
	fi

	# doc
	_mkdir "$DIR_DOC"
	_cp doc/* "$DIR_DOC"

	# lib
	_mkdir "$DIR_LIB"
	_cp base.sh "$DIR_LIB"

	# log
	_sudo touch "$FILE_LOG"
	_sudo chmod 666 "$FILE_LOG"

	# run
	# By Hue-shell generated run files that should "survive" reboot.
	_mkdir "$DIR_RUN_PERM"
	_sudo chmod 777 "$DIR_RUN_PERM"
	_sudo touch "$FILE_RANDOM_SEED"
	_sudo chmod 666 "$FILE_RANDOM_SEED"
	_sudo touch "$FILE_PIDS"
	_sudo chmod 666 "$FILE_PIDS"
}

_install_services() {
	# OpenWrt
	if [ -f /etc/openwrt_version ]; then
		echo "Installing init.d services ..."
		_install() {
			_cp "service/openwrt.initd/$1" "/etc/init.d/hue-$1"
			if [ -z "$UPGRADE" ]; then
				"/etc/init.d/hue-$1" enable
			fi
		}
		_install load-default
		_install detect-lights
		_install detect-bridge

	# systemd
	elif command -v systemctl > /dev/null 2>&1; then
		echo "Installing systemd services ..."
		_install() {
			_cp "service/systemd/$1" "/lib/systemd/system/hue-$1.service"
			if [ -z "$UPGRADE" ]; then
				_sudo systemctl enable "/lib/systemd/system/hue-$1.service"
			fi
		}
		_install load-default
		_install detect-lights
		_install detect-bridge

	# SysVinit
	elif [ -d '/etc/init.d' ]; then
		echo "Installing SysVinit services ..."
		_install() {
			_cp "service/SysVinit/$1" "/etc/init.d/$1"
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

	if [ "$NO_CONFIG" = 1 ]; then
		# shellcheck disable=SC1091
		. ./config/hue-shell.conf
	fi
	_install_base
	_install_services
	_install_triggerhappy
	_cleanup
}

_restore_configuration() {
	_replace() {
		_sudo sed -i.test.bak "s;$1;$2;" /etc/hue-shell/hue-shell.conf
	}

	while true ; do
		case "$1" in
			-a|--all-lights)
				R_ALL_LIGHTS=$2
				shift 2
				;;

			-d|--debug)
				R_DEBUG=$2
				shift 2
				;;

			-g|--gamut)
				R_GAMUT=$2
				shift 2
				;;

			-i|--ip)
				R_IP=$2
				shift 2
				;;

			-l|--log)
				R_LOG=$2
				shift 2
				;;

			-t|--test)
				R_TEST=$2
				shift 2
				;;

			-u|--username)
				R_USERNAME=$2
				shift 2
				;;

			*)
				break
				;;
		esac
	done

	if [ -n "$R_ALL_LIGHTS" ]; then _replace 'ALL_LIGHTS="1,2,3"' "ALL_LIGHTS=\"$R_ALL_LIGHTS\"" ; fi
	if [ -n "$R_DEBUG" ]; then _replace 'DEBUG=0' "DEBUG=$R_DEBUG" ; fi
	if [ -n "$R_GAMUT" ]; then _replace 'GAMUT="B"' "GAMUT=\"$R_GAMUT\"" ; fi
	if [ -n "$R_IP" ]; then _replace 'IP="192.168.1.2"' "IP=\"$R_IP\"" ; fi
	if [ -n "$R_LOG" ]; then _replace 'LOG=0' "LOG=$R_LOG" ; fi
	if [ -n "$R_TEST" ]; then _replace 'TEST=0' "TEST=$R_TEST" ; fi
	if [ -n "$R_USERNAME" ]; then _replace 'USERNAME="yourusername"' "USERNAME=\"$R_USERNAME\"" ; fi
}

_uninstall() {
	if [ "$1" = '--purge' ]; then
		PURGE=1
		shift
	fi

	if [ ! "$@" = '-y' ]; then
		echo 'Uninstall hue-shell? (y|n): '

		read -r COMFIRMATION

		if [ ! "$COMFIRMATION" = 'y' ]; then
			exit 1
		fi
	fi

	_rm "$DIR_LIB"
	_rm "$DIR_BIN"/hue*
	_rm "$DIR_DOC"

	if [ "$PURGE" = 1 ]; then
		_rm "$DIR_CONF"
		_rm "$DIR_RUN_PERM"
		_rm "$DIR_RUN_TMP/$NAME-lights-reachable"
		_rm "$DIR_RUN_TMP/$NAME-lights-all"
		_rm "$DIR_LOG/$NAME.log"
		_rm /etc/triggerhappy/triggers.d/hue-shell.conf
	fi

	# OpenWrt
	if [ -f /etc/openwrt_version ]; then
		_disable() {
			"/etc/init.d/hue-$1" disable
		}
		_disable load-default
		_disable detect-lights
		_disable detect-bridge

	elif command -v systemctl > /dev/null 2>&1; then
		echo "Uninstall systemd services ..."
		_disable() {
			_sudo systemctl disable "hue-$1.service"
		}
		_disable load-default
		_disable detect-lights
		_disable detect-bridge
		_rm /lib/systemd/system/hue*
	fi

	_rm /etc/init.d/hue-*
}

case "$OPT" in

	help)
		_usage
		;;

	install)
		_install
		if [ "$#" -gt 0 ]; then shift; fi
		# shellcheck disable=SC2068
		_restore_configuration $@
		;;

	purge)
		# shellcheck disable=SC2068
		_uninstall --purge $@
		;;

	reinstall)
		_uninstall -y
		_install
		if [ "$#" -gt 0 ]; then shift; fi
		# shellcheck disable=SC2068
		_restore_configuration $@
		;;

	upgrade)
		UPGRADE=1
		_install
		;;

	uninstall)
		# shellcheck disable=SC2068
		_uninstall $@
		;;

	*)
		_usage 1
		;;

esac

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
