#! /bin/sh

########################################################################
# Checks
########################################################################

PIDFILE='/var/run/hue-shell/hue-shell.pids'
SEED_FILE='/var/run/hue-shell/hue-shell-random.seed'

##
# Loop function.
##
_hue_loop() {
	(
		while true; do
			eval "$*"
		done
	) &
	echo $! >> $PIDFILE
}

##
# Random range function.
#
# - $1 = RANGE (3:7)
#
# Solution with /dev/urandom:
# RANDOM=$(tr -cd 0-9 < /dev/urandom | head -c 6)
# RANDOM="1$RANDOM"
##
_hue_range() {
	local START=${1%%:*}
	local END=${1#*:}

	END=$((END + 1))
	local RANGE=$((END - START))

	# http://rosettacode.org/wiki/Linear_congruential_generator

	SEED=$(cat $SEED_FILE)
	SEED=$(((123 * $SEED + 23456) % 345678))
	echo $SEED > $SEED_FILE

	RANDOM=$(($SEED / 2))

	local NUMBER_IN_RANGE=$((RANDOM % RANGE))

	echo $((NUMBER_IN_RANGE + START))
}

##
# Execute the http call over curl.
#
# - $1 = HTTP_REQUEST: PUT, GET
# - $2 = PATH:
# - $3 = JSON:
##
_hue_call() {

	if [ -n "$3" ]; then
		local DATA="--data $3"
	fi

	curl --silent --request $1 $DATA http://$IP/api/$USERNAME/$2 | _hue_output
}

##
# Stop all hue processes.
##
_hue_stop() {

	for PID in $(cat $PIDFILE); do
		kill $PID > /dev/null 2>&1
	done

	> $PIDFILE
}

##
# Kill all hue process.
#
# Goal of this function is to kill all process (background,
# other terminals.)
##
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
		hueload-scenes \
		huescene-breath \
		huescene-pendulum \
		huescene-sequence \
		> /dev/null 2>&1
}

##
# Stop all hue processes and reset to default color.
##
_hue_reset() {
	_hue_stop
	_hue_set all --ct 369 --bri 254
}

##
# Set light state.
#
# - $1 = LIGHTS
# - $@ = LIGHT_ATTRIBUTES
##
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

##
# Set light state with transistion time an sleep.
#
# $1 = LIGHTS:
# $2 = TRANSITIONTIME: in seconds
##
_hue_set_transit() {
	local LIGHTS="$1"
	local TRANSITIONTIME="$2"
	shift 2

	_hue_set $LIGHTS --transitiontime $(($TRANSITIONTIME * 10)) $@
	sleep $TRANSITIONTIME
}

##
# Get the state of the lights.
#
# - $1 = LIGHTS
##
_hue_get() {

	local LIGHTS="$1"
	shift

	DEBUG="YES"

	if [ "$LIGHTS" = "all" ]; then

		_hue_call GET lights
	else

		OLD_IFS=$IFS; IFS=","

		for LIGHT in $LIGHTS; do
			IFS=$OLD_IFS

			_hue_call GET lights/$LIGHT
		done

	fi

}

##
# Perform one breathe cycle.
#
# - $1 = LIGHTS
##
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

##
# Print out debug output in three modes.
##
_hue_output() {
	read OUTPUT

	if [ $DEBUG = "YES" ]; then
		echo $OUTPUT | tr ',' '\n'
	fi
}

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;