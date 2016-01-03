#! /bin/sh

PIDFILE="$HOME/.config/hue-shell/hue-shell.pids"
SEED_FILE="$HOME/.config/hue-shell/hue-shell-random.seed"

# Execute hue commands and put them in a while loop.
#	$*: HUE_COMMANDS
_hue_loop() {
	(
		while true; do
			eval "$*"
		done
	) &
	echo $! >> $PIDFILE
}

# Random range function.
# 	$1: RANGE (3:7)
#
# Solution with /dev/urandom:
#	RANDOM=$(tr -cd 0-9 < /dev/urandom | head -c 6)
#	RANDOM="1$RANDOM"
_hue_range() {
	local START=${1%%:*}
	local END=${1#*:}

	END=$((END + 1))
	local RANGE=$((END - START))

	# http://rosettacode.org/wiki/Linear_congruential_generator

	SEED=$(cat $SEED_FILE | head -n 1)
	SEED=$(((123 * $SEED + 23456) % 345678))
	echo $SEED > $SEED_FILE

	RANDOM=$(($SEED / 2))

	local NUMBER_IN_RANGE=$((RANDOM % RANGE))

	echo $((NUMBER_IN_RANGE + START))
}

# Execute the http call over curl.
#	$1: HTTP_REQUEST: PUT, GET
#	$2: PATH
#	$3: JSON
_hue_call() {

	if [ -n "$3" ]; then
		local DATA="--data $3"
	fi

	curl --silent --request $1 $DATA http://$IP/api/$USERNAME/$2 | _hue_output
}

# Stop all hue processes.
_hue_stop() {

	for PID in $(cat $PIDFILE); do
		kill $PID > /dev/null 2>&1
	done

	> $PIDFILE
}

# Kill all hue processes.
_hue_kill() {
	_hue_reset

	# Alternatives:
	# - pkill (not on openwrt, busybox)
	# - ps -w | grep "hue" | awk '{print $1}'

	killall \
		hue \
		huecolor-basic \
		huecolor-recipe \
		hueload-random \
		hueload-scene \
		huescene-breath \
		huescene-pendulum \
		huescene-sequence \
		> /dev/null 2>&1
}

# Stop all hue processes and reset the lights to the default color.
_hue_reset() {
	_hue_stop
	_hue_set all --ct 369 --bri 254
}

# Set light state.
#	$1: LIGHTS
#	$@: LIGHT_ATTRIBUTES
_hue_set() {
	local LIGHTS="$1"
	shift
	local JSON=""

	while true ; do
		case "$1" in

			--on)
				JSON="$JSON,\"on\":true"
				shift 1
				;;

			--off)
				JSON="$JSON,\"on\":false"
				shift 1
				;;

			-b|--bri|--brightness)
				JSON="$JSON,\"bri\":$2"
				shift 2
				;;

			-h|--hue)
				JSON="$JSON,\"hue\":$2"
				shift 2
				;;

			-s|--sat|--saturation)
				JSON="$JSON,\"sat\":$2"
				shift 2
				;;

			-x)
				local X=$2
				shift 2
				;;

			-y)
				local Y=$2
				shift 2
				;;

			-c|--ct)
				JSON="$JSON,\"ct\":$2"
				shift 2
				;;

			-a|--alert)
				JSON="$JSON,\"alert\":\"$2\""
				shift 2
				;;

			-e|--effect)
				JSON="$JSON,\"effect\":\"$2\""
				shift 2
				;;

			-t|--transitiontime)
				JSON="$JSON,\"transitiontime\":$2"
				shift 2
				;;

			-H|--help)
				_hue_set_help
				break
				;;

			*)
				if [ -n "$1" ]; then
					_hue_set_help
				fi
				break
				;;
		esac
	done

	if [ $X ] && [ $Y ]; then
		JSON="$JSON,\"xy\":[$X,$Y]"
	fi

	JSON=$(echo "$JSON" | tail -c +2)
	JSON="{$JSON}"

	if [ "$LIGHTS" = "all" ]; then
		_hue_call PUT groups/0/action $JSON
	else
		OLD_IFS=$IFS; IFS=","
		for LIGHT in $LIGHTS; do
			IFS=$OLD_IFS
			_hue_call PUT lights/$LIGHT/state "$JSON"
		done
	fi
}

# Set the light state with transistion and sleep time.
#	$1: LIGHTS
#	$2: TRANSITIONTIME
_hue_set_transit() {
	local LIGHTS="$1"
	local TRANSITIONTIME="$2"
	shift 2

	_hue_set $LIGHTS --transitiontime $(($TRANSITIONTIME * 10)) $@
	sleep $TRANSITIONTIME
}

# Get the state of the lights.
#	$1: LIGHTS
_hue_get() {
	local LIGHTS="$1"
	shift

	DEBUG="YES"

	if [ "$LIGHTS" = "all" ]; then
		_hue_call GET lights
	elif [ "$LIGHTS" = "on" ]; then
		_hue_get_on
	else
		OLD_IFS=$IFS; IFS=","
		for LIGHT in $LIGHTS; do
			IFS=$OLD_IFS
			_hue_call GET lights/$LIGHT
		done
	fi
}

# Queries for lights, which are online.
_hue_get_on() {
	local JSON IS_LIGHT IS_REACHABLE OUTPUT LINE

	JSON=$(curl --silent --request GET http://$IP/api/$USERNAME/lights | sed 's/"\([0-9]*\)":{"state":/%\1%/g')

	OLD_IFS=$IFS; IFS="%"
	IS_LIGHT=0
	for LINE in $JSON; do
		IFS=$OLD_IFS
		if [ "$IS_LIGHT" = 0 ]; then
			IS_LIGHT=1
			IS_REACHABLE=$(echo $LINE | grep '"reachable":true')
			if [ -n "$IS_REACHABLE" ]; then
				OUTPUT="$OUTPUT,$LIGHT"
			fi
		else
			IS_LIGHT=0
			LIGHT=$LINE
		fi
	done

        echo $OUTPUT | sed 's/^,//'
}

# Perform one breathe cycle.
#	$1: LIGHTS
_hue_alert() {
	local LIGHTS="$1"
	shift

	if [ "$LIGHTS" = "all" ]; then
		_hue_call PUT groups/0/action '{"alert":"select"}'
	else
		OLD_IFS=$IFS; IFS=","
		for LIGHT in $LIGHTS; do
			IFS=$OLD_IFS
			_hue_call PUT lights/$LIGHT/state '{"alert":"select"}'
		done
	fi
}

# Print out debug output in three modes.
_hue_output() {
	read OUTPUT

	if [ $DEBUG = "YES" ]; then
		echo $OUTPUT | tr ',' '\n'
	fi
}

# Show help messages.
_hue_usage() {
	cat /usr/share/doc/hue-shell/$1.txt
	echo ''
	exit 0
}

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
