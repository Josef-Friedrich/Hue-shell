#! /bin/sh

OLD_IFS="$IFS"
BASENAME="$(basename "$0")"

# Execute hue commands and put them in a while loop.
#	$*: HUE_COMMANDS
_hue_loop() {
	(
		while true; do
			eval "$*"
		done
	) &
	echo $! >> "$FILE_PIDS"
}

# Random range function.
# 	$1: RANGE (3:7)
#
# Solution with /dev/urandom:
#	RANDOM=$(tr -cd 0-9 < /dev/urandom | head -c 6)
#	RANDOM="1$RANDOM"
_hue_range() {
	START=${1%%:*}
	END=${1#*:}

	END=$((END + 1))
	RANGE=$((END - START))

	# http://rosettacode.org/wiki/Linear_congruential_generator

	SEED=$(head -n 1 < "$FILE_RANDOM_SEED")
	SEED=$(((123 * SEED + 23456) % 345678))
	echo "$SEED" > "$FILE_RANDOM_SEED"

	RAND=$((SEED / 2))

	NUMBER_IN_RANGE=$((RAND % RANGE))

	echo $((NUMBER_IN_RANGE + START))
}

# Print to Stdout for bats tests
_hue_test() {
	echo "$3"
}

# Execute the http call over curl.
#	$1: HTTP_REQUEST: PUT, GET
#	$2: PATH
#	$3: JSON
_hue_call() {
	if [ -n "$3" ]; then
		DATA="--data $3"
	fi
	_hue_log 2 "HTTP_REQUEST: $1 PATH: $2 DATA: $3"
	if [ "$TEST" = 1 ]; then
		_hue_test "$@"
	else
		# shellcheck disable=SC2086
		curl \
			--max-time 1 \
			--silent \
			--request "$1" $DATA "http://$IP/api/$USERNAME/$2" | _hue_output
	fi
}

# Stop all hue processes.
_hue_stop() {
	# shellcheck disable=SC2013
	for PID in $(cat "$FILE_PIDS"); do
		kill "$PID" > /dev/null 2>&1
	done
	> "$FILE_PIDS"
}

# Kill all hue processes.
_hue_kill() {
	_hue_reset

	# Alternatives:
	# - pkill (not on openwrt, busybox)
	# - ps -w | grep "hue" | awk '{print $1}'

	# hueload-random is not killed. _hue_kill is needed inside hueload-random
	killall -9 \
		hue \
		huecolor-basic \
		huecolor-recipe \
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
	if [ -z "${1}" ]; then
		_hue_usage error
	fi
	LIGHTS="$1"
	shift
	JSON=""

	while true ; do
		case "$1" in

			-a|--alert)
				JSON="$JSON,\"alert\":\"$2\""
				shift 2
				;;

			-b|--bri|--brightness)
				JSON="$JSON,\"bri\":$2"
				shift 2
				;;

			-c|--ct)
				JSON="$JSON,\"ct\":$2"
				shift 2
				;;

			-e|--effect)
				JSON="$JSON,\"effect\":\"$2\""
				shift 2
				;;

			-H|--help)
				_hue_usage
				break
				;;

			-h|--hue)
				JSON="$JSON,\"hue\":$2"
				shift 2
				;;

			--off)
				JSON="$JSON,\"on\":false"
				shift 1
				;;

			--on)
				JSON="$JSON,\"on\":true"
				shift 1
				;;

			-s|--sat|--saturation)
				JSON="$JSON,\"sat\":$2"
				shift 2
				;;

			-x)
				X=$2
				shift 2
				;;

			-y)
				Y=$2
				shift 2
				;;

			-t|--transitiontime)
				JSON="$JSON,\"transitiontime\":$2"
				shift 2
				;;

			*)
				if [ -n "$1" ]; then
					_hue_usage error
				fi
				break
				;;
		esac
	done

	if [ "$X" ] && [ "$Y" ]; then
		JSON="$JSON,\"xy\":[$X,$Y]"
	fi

	JSON=$(echo "$JSON" | tail -c +2)
	JSON="{$JSON}"

	if [ "$DEBUG" -ge 2 ]; then
		echo "$JSON"
	fi

	if [ "$LIGHTS" = "all" ]; then
		_hue_call PUT groups/0/action "$JSON"
	else
		IFS=","
		for LIGHT in $LIGHTS; do
			IFS="$OLD_IFS"
			_hue_call PUT "lights/$LIGHT/state" "$JSON"
		done
	fi
}

# Set the light state with transistion and sleep time.
#	$1: LIGHTS
#	$2: TRANSITIONTIME
_hue_set_transit() {
	LIGHTS="$1"
	TRANSITIONTIME="$2"
	shift 2

	_hue_set "$LIGHTS" --transitiontime $((TRANSITIONTIME * 10)) "$@"
	sleep "$TRANSITIONTIME"
}

# Get the state of the lights.
#	$1: LIGHTS
_hue_get() {
	LIGHTS="$1"
	shift

	DEBUG=1

	if [ "$LIGHTS" = "all" ]; then
		_hue_call GET lights
	elif [ "$LIGHTS" = "on" ]; then
		# shellcheck disable=SC2119
		_hue_get_on
	else
		IFS=","
		for LIGHT in $LIGHTS; do
			IFS="$OLD_IFS"
			_hue_call GET "lights/$LIGHT"
		done
	fi
}

# Queries for lights, which are online.
# shellcheck disable=SC2120
_hue_get_on() {
	if [ -n "$1" ]; then
		JSON=$(cat "$1")
	else
		JSON=$(curl --silent --request GET "http://$IP/api/$USERNAME/lights")
	fi
	JSON=$(echo "$JSON" | sed 's/"\([0-9]*\)":{"state":/%\1%/g')

	IFS="%"
	IS_LIGHT=0
	for LINE in $JSON; do
		IFS="$OLD_IFS"
		if [ "$IS_LIGHT" = 0 ]; then
			IS_LIGHT=1
			IS_REACHABLE=$(echo "$LINE" | grep '"reachable":true')
			if [ -n "$IS_REACHABLE" ]; then
				OUTPUT="$OUTPUT,$LIGHT"
			fi
		else
			IS_LIGHT=0
			LIGHT=$LINE
		fi
	done

	echo "$OUTPUT" | sed 's/^,//'
}

# This funtion checks if there reachable lights and returns it.
# Otherwise it returns the value of the $ALL_LIGHTS variable.
_hue_get_lights_reachable() {
	if [ -f "$FILE_LIGHTS_REACHABLE" ]; then
		cat "$FILE_LIGHTS_REACHABLE"
	else
		echo "$ALL_LIGHTS"
	fi
}

# Perform one breathe cycle.
#	$1: LIGHTS
_hue_alert() {
	LIGHTS="$1"
	shift

	if [ "$LIGHTS" = "all" ]; then
		_hue_call PUT groups/0/action '{"alert":"select"}'
	else
		IFS=","
		for LIGHT in $LIGHTS; do
			IFS="$OLD_IFS"
			_hue_call PUT "lights/$LIGHT/state" '{"alert":"select"}'
		done
	fi
}

# Trap function for scene scripts. If you hit Ctrl+c, the light scence
# will be interrupted and all lights will be reset to the default color.
_hue_trap() {
	if [ -z "$1" ]; then
		TRAP="_hue_reset; echo; exit"
	else
		TRAP="$1"
	fi
	trap '$TRAP' $DEFAULT_TRAP_SIGNALS
}

# Print out debug output in three modes.
_hue_output() {
	read -r OUTPUT

	if [ "$DEBUG" -ge 1 ]; then
		echo "$OUTPUT" | tr ',' '\n'
	fi
}

# Log messages to a log file.
#	$1: LOG_LEVEL
#	$2: LOG_MESSAGE
_hue_log() {
	if [ "$LOG" -ge "$1" ]; then
		echo "$(date) [$BASENAME] $2" >> "$FILE_LOG"
	fi

	if [ "$DEBUG" -ge "$1" ]; then
		echo "$2"
	fi
}

# Show help messages.
_hue_usage() {
	cat "${PREFIX}/share/doc/hue-shell/${BASENAME}.txt"
	echo ''
	if [ "$1" = 'error' ]; then
		exit 1
	else
		exit 0
	fi
}

# Convert color strings to hue values.
_hue_color() {
	case "$1" in
		blue) echo 46920 ;;
		cyan) echo 56100 ;;
		green) echo 25500 ;;
		red) echo 0 ;;
		white) echo 36210 ;;
		yellow) echo 12750 ;;
		*) echo 0 ;;
	esac
}


# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
