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
	# Gamut B
	if [ "$2" = 'B' ]; then
		case "$1" in
			alice-blue) COLOR='-x 0.3092 -y 0.321' ;;
			antique-white) COLOR='-x 0.3548 -y 0.3489' ;;
			aqua) COLOR='-x 0.2858 -y 0.2747' ;;
			aquamarine) COLOR='-x 0.3237 -y 0.3497' ;;
			azure) COLOR='-x 0.3123 -y 0.3271' ;;
			beige) COLOR='-x 0.3402 -y 0.356' ;;
			bisque) COLOR='-x 0.3806 -y 0.3576' ;;
			black) COLOR='-x 0.168 -y 0.041' ;;
			blanched-almond) COLOR='-x 0.3695 -y 0.3584' ;;
			blue) COLOR='-x 0.168 -y 0.041' ;;
			blue-violet) COLOR='-x 0.251 -y 0.1056' ;;
			brown) COLOR='-x 0.6399 -y 0.3041' ;;
			burlywood) COLOR='-x 0.4236 -y 0.3811' ;;
			cadet-blue) COLOR='-x 0.2961 -y 0.295' ;;
			chartreuse) COLOR='-x 0.408 -y 0.517' ;;
			chocolate) COLOR='-x 0.6009 -y 0.3684' ;;
			coral) COLOR='-x 0.5763 -y 0.3486' ;;
			cornflower) COLOR='-x 0.2343 -y 0.1725' ;;
			cornsilk) COLOR='-x 0.3511 -y 0.3574' ;;
			crimson) COLOR='-x 0.6417 -y 0.304' ;;
			cyan) COLOR='-x 0.2858 -y 0.2747' ;;
			dark-blue) COLOR='-x 0.168 -y 0.041' ;;
			dark-cyan) COLOR='-x 0.2858 -y 0.2747' ;;
			dark-goldenrod) COLOR='-x 0.5204 -y 0.4346' ;;
			dark-gray) COLOR='-x 0.3227 -y 0.329' ;;
			dark-green) COLOR='-x 0.408 -y 0.517' ;;
			dark-khaki) COLOR='-x 0.4004 -y 0.4331' ;;
			dark-magenta) COLOR='-x 0.3824 -y 0.1601' ;;
			dark-olive-green) COLOR='-x 0.3908 -y 0.4829' ;;
			dark-orange) COLOR='-x 0.5916 -y 0.3824' ;;
			dark-orchid) COLOR='-x 0.2986 -y 0.1341' ;;
			dark-red) COLOR='-x 0.674 -y 0.322' ;;
			dark-salmon) COLOR='-x 0.4837 -y 0.3479' ;;
			dark-sea-green) COLOR='-x 0.3429 -y 0.3879' ;;
			dark-slate-blue) COLOR='-x 0.2218 -y 0.1477' ;;
			dark-slate-gray) COLOR='-x 0.2982 -y 0.2993' ;;
			dark-turquoise) COLOR='-x 0.2835 -y 0.2701' ;;
			dark-violet) COLOR='-x 0.2836 -y 0.1079' ;;
			deep-pink) COLOR='-x 0.5386 -y 0.2468' ;;
			deep-sky-blue) COLOR='-x 0.2428 -y 0.1893' ;;
			dim-gray) COLOR='-x 0.3227 -y 0.329' ;;
			dodger-blue) COLOR='-x 0.2115 -y 0.1273' ;;
			firebrick) COLOR='-x 0.6566 -y 0.3123' ;;
			floral-white) COLOR='-x 0.3361 -y 0.3388' ;;
			forest-green) COLOR='-x 0.408 -y 0.517' ;;
			fuchsia) COLOR='-x 0.3824 -y 0.1601' ;;
			gainsboro) COLOR='-x 0.3227 -y 0.329' ;;
			ghost-white) COLOR='-x 0.3174 -y 0.3207' ;;
			gold) COLOR='-x 0.4859 -y 0.4599' ;;
			goldenrod) COLOR='-x 0.5113 -y 0.4413' ;;
			gray) COLOR='-x 0.3227 -y 0.329' ;;
			web-gray) COLOR='-x 0.3227 -y 0.329' ;;
			green) COLOR='-x 0.408 -y 0.517' ;;
			web-green) COLOR='-x 0.408 -y 0.517' ;;
			green-yellow) COLOR='-x 0.408 -y 0.517' ;;
			honeydew) COLOR='-x 0.3213 -y 0.345' ;;
			hot-pink) COLOR='-x 0.4682 -y 0.2452' ;;
			indian-red) COLOR='-x 0.5488 -y 0.3112' ;;
			indigo) COLOR='-x 0.2437 -y 0.0895' ;;
			ivory) COLOR='-x 0.3334 -y 0.3455' ;;
			khaki) COLOR='-x 0.4019 -y 0.4261' ;;
			lavender) COLOR='-x 0.3085 -y 0.3071' ;;
			lavender-blush) COLOR='-x 0.3369 -y 0.3225' ;;
			lawn-green) COLOR='-x 0.408 -y 0.517' ;;
			lemon-chiffon) COLOR='-x 0.3608 -y 0.3756' ;;
			light-blue) COLOR='-x 0.2975 -y 0.2979' ;;
			light-coral) COLOR='-x 0.5075 -y 0.3145' ;;
			light-cyan) COLOR='-x 0.3096 -y 0.3218' ;;
			light-goldenrod) COLOR='-x 0.3504 -y 0.3717' ;;
			light-gray) COLOR='-x 0.3227 -y 0.329' ;;
			light-green) COLOR='-x 0.3682 -y 0.438' ;;
			light-pink) COLOR='-x 0.4112 -y 0.3091' ;;
			light-salmon) COLOR='-x 0.5016 -y 0.3531' ;;
			light-sea-green) COLOR='-x 0.2946 -y 0.292' ;;
			light-sky-blue) COLOR='-x 0.2714 -y 0.246' ;;
			light-slate-gray) COLOR='-x 0.2924 -y 0.2877' ;;
			light-steel-blue) COLOR='-x 0.293 -y 0.2889' ;;
			light-yellow) COLOR='-x 0.3436 -y 0.3612' ;;
			lime) COLOR='-x 0.408 -y 0.517' ;;
			lime-green) COLOR='-x 0.408 -y 0.517' ;;
			linen) COLOR='-x 0.3411 -y 0.3387' ;;
			magenta) COLOR='-x 0.3824 -y 0.1601' ;;
			maroon) COLOR='-x 0.5383 -y 0.2566' ;;
			web-maroon) COLOR='-x 0.674 -y 0.322' ;;
			medium-aquamarine) COLOR='-x 0.3224 -y 0.3473' ;;
			medium-blue) COLOR='-x 0.168 -y 0.041' ;;
			medium-orchid) COLOR='-x 0.3365 -y 0.1735' ;;
			medium-purple) COLOR='-x 0.263 -y 0.1773' ;;
			medium-sea-green) COLOR='-x 0.3588 -y 0.4194' ;;
			medium-slate-blue) COLOR='-x 0.2189 -y 0.1419' ;;
			medium-spring-green) COLOR='-x 0.3622 -y 0.4262' ;;
			medium-turquoise) COLOR='-x 0.2937 -y 0.2903' ;;
			medium-violet-red) COLOR='-x 0.5002 -y 0.2255' ;;
			midnight-blue) COLOR='-x 0.1825 -y 0.0697' ;;
			mint-cream) COLOR='-x 0.3165 -y 0.3355' ;;
			misty-rose) COLOR='-x 0.3581 -y 0.3284' ;;
			moccasin) COLOR='-x 0.3927 -y 0.3732' ;;
			navajo-white) COLOR='-x 0.4027 -y 0.3757' ;;
			navy-blue) COLOR='-x 0.168 -y 0.041' ;;
			old-lace) COLOR='-x 0.3421 -y 0.344' ;;
			olive) COLOR='-x 0.4317 -y 0.4996' ;;
			olive-drab) COLOR='-x 0.408 -y 0.517' ;;
			orange) COLOR='-x 0.5562 -y 0.4084' ;;
			orange-red) COLOR='-x 0.6733 -y 0.3224' ;;
			orchid) COLOR='-x 0.3688 -y 0.2095' ;;
			pale-goldenrod) COLOR='-x 0.3751 -y 0.3983' ;;
			pale-green) COLOR='-x 0.3657 -y 0.4331' ;;
			pale-turquoise) COLOR='-x 0.3034 -y 0.3095' ;;
			pale-violet-red) COLOR='-x 0.4658 -y 0.2773' ;;
			papaya-whip) COLOR='-x 0.3591 -y 0.3536' ;;
			peach-puff) COLOR='-x 0.3953 -y 0.3564' ;;
			peru) COLOR='-x 0.5305 -y 0.3911' ;;
			pink) COLOR='-x 0.3944 -y 0.3093' ;;
			plum) COLOR='-x 0.3495 -y 0.2545' ;;
			powder-blue) COLOR='-x 0.302 -y 0.3068' ;;
			purple) COLOR='-x 0.2725 -y 0.1096' ;;
			web-purple) COLOR='-x 0.3824 -y 0.1601' ;;
			rebecca-purple) COLOR='-x 0.2703 -y 0.1398' ;;
			red) COLOR='-x 0.674 -y 0.322' ;;
			rosy-brown) COLOR='-x 0.4026 -y 0.3227' ;;
			royal-blue) COLOR='-x 0.2047 -y 0.1138' ;;
			saddle-brown) COLOR='-x 0.5993 -y 0.369' ;;
			salmon) COLOR='-x 0.5346 -y 0.3247' ;;
			sandy-brown) COLOR='-x 0.5104 -y 0.3826' ;;
			sea-green) COLOR='-x 0.3602 -y 0.4223' ;;
			seashell) COLOR='-x 0.3397 -y 0.3353' ;;
			sienna) COLOR='-x 0.5714 -y 0.3559' ;;
			silver) COLOR='-x 0.3227 -y 0.329' ;;
			sky-blue) COLOR='-x 0.2807 -y 0.2645' ;;
			slate-blue) COLOR='-x 0.2218 -y 0.1444' ;;
			slate-gray) COLOR='-x 0.2944 -y 0.2918' ;;
			snow) COLOR='-x 0.3292 -y 0.3285' ;;
			spring-green) COLOR='-x 0.3882 -y 0.4777' ;;
			steel-blue) COLOR='-x 0.248 -y 0.1997' ;;
			tan) COLOR='-x 0.4035 -y 0.3772' ;;
			teal) COLOR='-x 0.2858 -y 0.2747' ;;
			thistle) COLOR='-x 0.3342 -y 0.2971' ;;
			tomato) COLOR='-x 0.6112 -y 0.3261' ;;
			turquoise) COLOR='-x 0.2997 -y 0.3022' ;;
			violet) COLOR='-x 0.3644 -y 0.2133' ;;
			wheat) COLOR='-x 0.3852 -y 0.3737' ;;
			white) COLOR='-x 0.3227 -y 0.329' ;;
			white-smoke) COLOR='-x 0.3227 -y 0.329' ;;
			yellow) COLOR='-x 0.4317 -y 0.4996' ;;
			yellow-green) COLOR='-x 0.408 -y 0.517' ;;
			*) COLOR='--alert select' ;;
		esac

	# Gamut C
	elif [ "$2" = 'C' ]; then
		case "$1" in
			alice-blue) COLOR='-x 0.3088 -y 0.3212' ;;
			antique-white) COLOR='-x 0.3548 -y 0.3489' ;;
			aqua) COLOR='-x 0.1607 -y 0.3423' ;;
			aquamarine) COLOR='-x 0.2138 -y 0.4051' ;;
			azure) COLOR='-x 0.3059 -y 0.3303' ;;
			beige) COLOR='-x 0.3402 -y 0.356' ;;
			bisque) COLOR='-x 0.3806 -y 0.3576' ;;
			black) COLOR='-x 0.153 -y 0.048' ;;
			blanched-almond) COLOR='-x 0.3695 -y 0.3584' ;;
			blue) COLOR='-x 0.153 -y 0.048' ;;
			blue-violet) COLOR='-x 0.251 -y 0.1056' ;;
			brown) COLOR='-x 0.6399 -y 0.3041' ;;
			burlywood) COLOR='-x 0.4236 -y 0.3811' ;;
			cadet-blue) COLOR='-x 0.2211 -y 0.3328' ;;
			chartreuse) COLOR='-x 0.2505 -y 0.6395' ;;
			chocolate) COLOR='-x 0.6009 -y 0.3684' ;;
			coral) COLOR='-x 0.5763 -y 0.3486' ;;
			cornflower) COLOR='-x 0.1905 -y 0.1945' ;;
			cornsilk) COLOR='-x 0.3511 -y 0.3574' ;;
			crimson) COLOR='-x 0.6508 -y 0.2881' ;;
			cyan) COLOR='-x 0.1607 -y 0.3423' ;;
			dark-blue) COLOR='-x 0.153 -y 0.048' ;;
			dark-cyan) COLOR='-x 0.1607 -y 0.3423' ;;
			dark-goldenrod) COLOR='-x 0.5214 -y 0.4361' ;;
			dark-gray) COLOR='-x 0.3227 -y 0.329' ;;
			dark-green) COLOR='-x 0.17 -y 0.7' ;;
			dark-khaki) COLOR='-x 0.4004 -y 0.4331' ;;
			dark-magenta) COLOR='-x 0.3833 -y 0.1591' ;;
			dark-olive-green) COLOR='-x 0.3475 -y 0.5047' ;;
			dark-orange) COLOR='-x 0.5921 -y 0.3831' ;;
			dark-orchid) COLOR='-x 0.2986 -y 0.1341' ;;
			dark-red) COLOR='-x 0.692 -y 0.308' ;;
			dark-salmon) COLOR='-x 0.4837 -y 0.3479' ;;
			dark-sea-green) COLOR='-x 0.2924 -y 0.4134' ;;
			dark-slate-blue) COLOR='-x 0.2206 -y 0.1484' ;;
			dark-slate-gray) COLOR='-x 0.2239 -y 0.3368' ;;
			dark-turquoise) COLOR='-x 0.1605 -y 0.3366' ;;
			dark-violet) COLOR='-x 0.2824 -y 0.1104' ;;
			deep-pink) COLOR='-x 0.5445 -y 0.2369' ;;
			deep-sky-blue) COLOR='-x 0.158 -y 0.2379' ;;
			dim-gray) COLOR='-x 0.3227 -y 0.329' ;;
			dodger-blue) COLOR='-x 0.1559 -y 0.1599' ;;
			firebrick) COLOR='-x 0.6621 -y 0.3023' ;;
			floral-white) COLOR='-x 0.3361 -y 0.3388' ;;
			forest-green) COLOR='-x 0.1984 -y 0.6746' ;;
			fuchsia) COLOR='-x 0.3833 -y 0.1591' ;;
			gainsboro) COLOR='-x 0.3227 -y 0.329' ;;
			ghost-white) COLOR='-x 0.3174 -y 0.3207' ;;
			gold) COLOR='-x 0.4871 -y 0.4618' ;;
			goldenrod) COLOR='-x 0.5125 -y 0.4428' ;;
			gray) COLOR='-x 0.3227 -y 0.329' ;;
			web-gray) COLOR='-x 0.3227 -y 0.329' ;;
			green) COLOR='-x 0.17 -y 0.7' ;;
			web-green) COLOR='-x 0.17 -y 0.7' ;;
			green-yellow) COLOR='-x 0.3221 -y 0.5857' ;;
			honeydew) COLOR='-x 0.316 -y 0.3477' ;;
			hot-pink) COLOR='-x 0.4682 -y 0.2452' ;;
			indian-red) COLOR='-x 0.5488 -y 0.3112' ;;
			indigo) COLOR='-x 0.2428 -y 0.0913' ;;
			ivory) COLOR='-x 0.3334 -y 0.3455' ;;
			khaki) COLOR='-x 0.4019 -y 0.4261' ;;
			lavender) COLOR='-x 0.3085 -y 0.3071' ;;
			lavender-blush) COLOR='-x 0.3369 -y 0.3225' ;;
			lawn-green) COLOR='-x 0.2485 -y 0.641' ;;
			lemon-chiffon) COLOR='-x 0.3608 -y 0.3756' ;;
			light-blue) COLOR='-x 0.2621 -y 0.3157' ;;
			light-coral) COLOR='-x 0.5075 -y 0.3145' ;;
			light-cyan) COLOR='-x 0.2901 -y 0.3316' ;;
			light-goldenrod) COLOR='-x 0.3504 -y 0.3717' ;;
			light-gray) COLOR='-x 0.3227 -y 0.329' ;;
			light-green) COLOR='-x 0.2648 -y 0.4901' ;;
			light-pink) COLOR='-x 0.4112 -y 0.3091' ;;
			light-salmon) COLOR='-x 0.5016 -y 0.3531' ;;
			light-sea-green) COLOR='-x 0.1611 -y 0.3593' ;;
			light-sky-blue) COLOR='-x 0.214 -y 0.2749' ;;
			light-slate-gray) COLOR='-x 0.2738 -y 0.297' ;;
			light-steel-blue) COLOR='-x 0.276 -y 0.2975' ;;
			light-yellow) COLOR='-x 0.3436 -y 0.3612' ;;
			lime) COLOR='-x 0.17 -y 0.7' ;;
			lime-green) COLOR='-x 0.1972 -y 0.6781' ;;
			linen) COLOR='-x 0.3411 -y 0.3387' ;;
			magenta) COLOR='-x 0.3833 -y 0.1591' ;;
			maroon) COLOR='-x 0.5383 -y 0.2566' ;;
			web-maroon) COLOR='-x 0.692 -y 0.308' ;;
			medium-aquamarine) COLOR='-x 0.215 -y 0.4014' ;;
			medium-blue) COLOR='-x 0.153 -y 0.048' ;;
			medium-orchid) COLOR='-x 0.3365 -y 0.1735' ;;
			medium-purple) COLOR='-x 0.263 -y 0.1773' ;;
			medium-sea-green) COLOR='-x 0.1979 -y 0.5005' ;;
			medium-slate-blue) COLOR='-x 0.2179 -y 0.1424' ;;
			medium-spring-green) COLOR='-x 0.1655 -y 0.5275' ;;
			medium-turquoise) COLOR='-x 0.176 -y 0.3496' ;;
			medium-violet-red) COLOR='-x 0.5047 -y 0.2177' ;;
			midnight-blue) COLOR='-x 0.1616 -y 0.0802' ;;
			mint-cream) COLOR='-x 0.315 -y 0.3363' ;;
			misty-rose) COLOR='-x 0.3581 -y 0.3284' ;;
			moccasin) COLOR='-x 0.3927 -y 0.3732' ;;
			navajo-white) COLOR='-x 0.4027 -y 0.3757' ;;
			navy-blue) COLOR='-x 0.153 -y 0.048' ;;
			old-lace) COLOR='-x 0.3421 -y 0.344' ;;
			olive) COLOR='-x 0.4334 -y 0.5022' ;;
			olive-drab) COLOR='-x 0.354 -y 0.5561' ;;
			orange) COLOR='-x 0.5569 -y 0.4095' ;;
			orange-red) COLOR='-x 0.6731 -y 0.3222' ;;
			orchid) COLOR='-x 0.3688 -y 0.2095' ;;
			pale-goldenrod) COLOR='-x 0.3751 -y 0.3983' ;;
			pale-green) COLOR='-x 0.2675 -y 0.4826' ;;
			pale-turquoise) COLOR='-x 0.2539 -y 0.3344' ;;
			pale-violet-red) COLOR='-x 0.4658 -y 0.2773' ;;
			papaya-whip) COLOR='-x 0.3591 -y 0.3536' ;;
			peach-puff) COLOR='-x 0.3953 -y 0.3564' ;;
			peru) COLOR='-x 0.5305 -y 0.3911' ;;
			pink) COLOR='-x 0.3944 -y 0.3093' ;;
			plum) COLOR='-x 0.3495 -y 0.2545' ;;
			powder-blue) COLOR='-x 0.262 -y 0.3269' ;;
			purple) COLOR='-x 0.2725 -y 0.1096' ;;
			web-purple) COLOR='-x 0.3833 -y 0.1591' ;;
			rebecca-purple) COLOR='-x 0.2703 -y 0.1398' ;;
			red) COLOR='-x 0.692 -y 0.308' ;;
			rosy-brown) COLOR='-x 0.4026 -y 0.3227' ;;
			royal-blue) COLOR='-x 0.1649 -y 0.1338' ;;
			saddle-brown) COLOR='-x 0.5993 -y 0.369' ;;
			salmon) COLOR='-x 0.5346 -y 0.3247' ;;
			sandy-brown) COLOR='-x 0.5104 -y 0.3826' ;;
			sea-green) COLOR='-x 0.1968 -y 0.5047' ;;
			seashell) COLOR='-x 0.3397 -y 0.3353' ;;
			sienna) COLOR='-x 0.5714 -y 0.3559' ;;
			silver) COLOR='-x 0.3227 -y 0.329' ;;
			sky-blue) COLOR='-x 0.2206 -y 0.2948' ;;
			slate-blue) COLOR='-x 0.2218 -y 0.1444' ;;
			slate-gray) COLOR='-x 0.2762 -y 0.3009' ;;
			snow) COLOR='-x 0.3292 -y 0.3285' ;;
			spring-green) COLOR='-x 0.1671 -y 0.5906' ;;
			steel-blue) COLOR='-x 0.183 -y 0.2325' ;;
			tan) COLOR='-x 0.4035 -y 0.3772' ;;
			teal) COLOR='-x 0.1607 -y 0.3423' ;;
			thistle) COLOR='-x 0.3342 -y 0.2971' ;;
			tomato) COLOR='-x 0.6112 -y 0.3261' ;;
			turquoise) COLOR='-x 0.1702 -y 0.3675' ;;
			violet) COLOR='-x 0.3644 -y 0.2133' ;;
			wheat) COLOR='-x 0.3852 -y 0.3737' ;;
			white) COLOR='-x 0.3227 -y 0.329' ;;
			white-smoke) COLOR='-x 0.3227 -y 0.329' ;;
			yellow) COLOR='-x 0.4334 -y 0.5022' ;;
			yellow-green) COLOR='-x 0.3517 -y 0.5618' ;;
			*) COLOR='--alert select' ;;
		esac

	# Gamut A
	else
		case "$1" in
			alice-blue) COLOR='-x 0.3088 -y 0.3212' ;;
			antique-white) COLOR='-x 0.3548 -y 0.3489' ;;
			aqua) COLOR='-x 0.17 -y 0.3403' ;;
			aquamarine) COLOR='-x 0.2138 -y 0.4051' ;;
			azure) COLOR='-x 0.3059 -y 0.3303' ;;
			beige) COLOR='-x 0.3402 -y 0.356' ;;
			bisque) COLOR='-x 0.3806 -y 0.3576' ;;
			black) COLOR='-x 0.139 -y 0.081' ;;
			blanched-almond) COLOR='-x 0.3695 -y 0.3584' ;;
			blue) COLOR='-x 0.139 -y 0.081' ;;
			blue-violet) COLOR='-x 0.245 -y 0.1214' ;;
			brown) COLOR='-x 0.6399 -y 0.3041' ;;
			burlywood) COLOR='-x 0.4236 -y 0.3811' ;;
			cadet-blue) COLOR='-x 0.2211 -y 0.3328' ;;
			chartreuse) COLOR='-x 0.2682 -y 0.6632' ;;
			chocolate) COLOR='-x 0.6009 -y 0.3684' ;;
			coral) COLOR='-x 0.5763 -y 0.3486' ;;
			cornflower) COLOR='-x 0.1905 -y 0.1945' ;;
			cornsilk) COLOR='-x 0.3511 -y 0.3574' ;;
			crimson) COLOR='-x 0.6531 -y 0.2834' ;;
			cyan) COLOR='-x 0.17 -y 0.3403' ;;
			dark-blue) COLOR='-x 0.139 -y 0.081' ;;
			dark-cyan) COLOR='-x 0.17 -y 0.3403' ;;
			dark-goldenrod) COLOR='-x 0.5265 -y 0.4428' ;;
			dark-gray) COLOR='-x 0.3227 -y 0.329' ;;
			dark-green) COLOR='-x 0.214 -y 0.709' ;;
			dark-khaki) COLOR='-x 0.4004 -y 0.4331' ;;
			dark-magenta) COLOR='-x 0.3787 -y 0.1724' ;;
			dark-olive-green) COLOR='-x 0.3475 -y 0.5047' ;;
			dark-orange) COLOR='-x 0.5951 -y 0.3872' ;;
			dark-orchid) COLOR='-x 0.296 -y 0.1409' ;;
			dark-red) COLOR='-x 0.7 -y 0.2986' ;;
			dark-salmon) COLOR='-x 0.4837 -y 0.3479' ;;
			dark-sea-green) COLOR='-x 0.2924 -y 0.4134' ;;
			dark-slate-blue) COLOR='-x 0.2206 -y 0.1484' ;;
			dark-slate-gray) COLOR='-x 0.2239 -y 0.3368' ;;
			dark-turquoise) COLOR='-x 0.1693 -y 0.3347' ;;
			dark-violet) COLOR='-x 0.2742 -y 0.1326' ;;
			deep-pink) COLOR='-x 0.5454 -y 0.2359' ;;
			deep-sky-blue) COLOR='-x 0.1576 -y 0.2368' ;;
			dim-gray) COLOR='-x 0.3227 -y 0.329' ;;
			dodger-blue) COLOR='-x 0.1484 -y 0.1599' ;;
			firebrick) COLOR='-x 0.6621 -y 0.3023' ;;
			floral-white) COLOR='-x 0.3361 -y 0.3388' ;;
			forest-green) COLOR='-x 0.2097 -y 0.6732' ;;
			fuchsia) COLOR='-x 0.3787 -y 0.1724' ;;
			gainsboro) COLOR='-x 0.3227 -y 0.329' ;;
			ghost-white) COLOR='-x 0.3174 -y 0.3207' ;;
			gold) COLOR='-x 0.4947 -y 0.472' ;;
			goldenrod) COLOR='-x 0.5136 -y 0.4444' ;;
			gray) COLOR='-x 0.3227 -y 0.329' ;;
			web-gray) COLOR='-x 0.3227 -y 0.329' ;;
			green) COLOR='-x 0.214 -y 0.709' ;;
			web-green) COLOR='-x 0.214 -y 0.709' ;;
			green-yellow) COLOR='-x 0.3298 -y 0.5959' ;;
			honeydew) COLOR='-x 0.316 -y 0.3477' ;;
			hot-pink) COLOR='-x 0.4682 -y 0.2452' ;;
			indian-red) COLOR='-x 0.5488 -y 0.3112' ;;
			indigo) COLOR='-x 0.2332 -y 0.1169' ;;
			ivory) COLOR='-x 0.3334 -y 0.3455' ;;
			khaki) COLOR='-x 0.4019 -y 0.4261' ;;
			lavender) COLOR='-x 0.3085 -y 0.3071' ;;
			lavender-blush) COLOR='-x 0.3369 -y 0.3225' ;;
			lawn-green) COLOR='-x 0.2663 -y 0.6649' ;;
			lemon-chiffon) COLOR='-x 0.3608 -y 0.3756' ;;
			light-blue) COLOR='-x 0.2621 -y 0.3157' ;;
			light-coral) COLOR='-x 0.5075 -y 0.3145' ;;
			light-cyan) COLOR='-x 0.2901 -y 0.3316' ;;
			light-goldenrod) COLOR='-x 0.3504 -y 0.3717' ;;
			light-gray) COLOR='-x 0.3227 -y 0.329' ;;
			light-green) COLOR='-x 0.2648 -y 0.4901' ;;
			light-pink) COLOR='-x 0.4112 -y 0.3091' ;;
			light-salmon) COLOR='-x 0.5016 -y 0.3531' ;;
			light-sea-green) COLOR='-x 0.1721 -y 0.358' ;;
			light-sky-blue) COLOR='-x 0.214 -y 0.2749' ;;
			light-slate-gray) COLOR='-x 0.2738 -y 0.297' ;;
			light-steel-blue) COLOR='-x 0.276 -y 0.2975' ;;
			light-yellow) COLOR='-x 0.3436 -y 0.3612' ;;
			lime) COLOR='-x 0.214 -y 0.709' ;;
			lime-green) COLOR='-x 0.2101 -y 0.6765' ;;
			linen) COLOR='-x 0.3411 -y 0.3387' ;;
			magenta) COLOR='-x 0.3787 -y 0.1724' ;;
			maroon) COLOR='-x 0.5383 -y 0.2566' ;;
			web-maroon) COLOR='-x 0.7 -y 0.2986' ;;
			medium-aquamarine) COLOR='-x 0.215 -y 0.4014' ;;
			medium-blue) COLOR='-x 0.139 -y 0.081' ;;
			medium-orchid) COLOR='-x 0.3365 -y 0.1735' ;;
			medium-purple) COLOR='-x 0.263 -y 0.1773' ;;
			medium-sea-green) COLOR='-x 0.1979 -y 0.5005' ;;
			medium-slate-blue) COLOR='-x 0.2179 -y 0.1424' ;;
			medium-spring-green) COLOR='-x 0.1919 -y 0.524' ;;
			medium-turquoise) COLOR='-x 0.176 -y 0.3496' ;;
			medium-violet-red) COLOR='-x 0.504 -y 0.2201' ;;
			midnight-blue) COLOR='-x 0.1585 -y 0.0884' ;;
			mint-cream) COLOR='-x 0.315 -y 0.3363' ;;
			misty-rose) COLOR='-x 0.3581 -y 0.3284' ;;
			moccasin) COLOR='-x 0.3927 -y 0.3732' ;;
			navajo-white) COLOR='-x 0.4027 -y 0.3757' ;;
			navy-blue) COLOR='-x 0.139 -y 0.081' ;;
			old-lace) COLOR='-x 0.3421 -y 0.344' ;;
			olive) COLOR='-x 0.4432 -y 0.5154' ;;
			olive-drab) COLOR='-x 0.354 -y 0.5561' ;;
			orange) COLOR='-x 0.5614 -y 0.4156' ;;
			orange-red) COLOR='-x 0.6726 -y 0.3217' ;;
			orchid) COLOR='-x 0.3688 -y 0.2095' ;;
			pale-goldenrod) COLOR='-x 0.3751 -y 0.3983' ;;
			pale-green) COLOR='-x 0.2675 -y 0.4826' ;;
			pale-turquoise) COLOR='-x 0.2539 -y 0.3344' ;;
			pale-violet-red) COLOR='-x 0.4658 -y 0.2773' ;;
			papaya-whip) COLOR='-x 0.3591 -y 0.3536' ;;
			peach-puff) COLOR='-x 0.3953 -y 0.3564' ;;
			peru) COLOR='-x 0.5305 -y 0.3911' ;;
			pink) COLOR='-x 0.3944 -y 0.3093' ;;
			plum) COLOR='-x 0.3495 -y 0.2545' ;;
			powder-blue) COLOR='-x 0.262 -y 0.3269' ;;
			purple) COLOR='-x 0.2651 -y 0.1291' ;;
			web-purple) COLOR='-x 0.3787 -y 0.1724' ;;
			rebecca-purple) COLOR='-x 0.2703 -y 0.1398' ;;
			red) COLOR='-x 0.7 -y 0.2986' ;;
			rosy-brown) COLOR='-x 0.4026 -y 0.3227' ;;
			royal-blue) COLOR='-x 0.1649 -y 0.1338' ;;
			saddle-brown) COLOR='-x 0.5993 -y 0.369' ;;
			salmon) COLOR='-x 0.5346 -y 0.3247' ;;
			sandy-brown) COLOR='-x 0.5104 -y 0.3826' ;;
			sea-green) COLOR='-x 0.1968 -y 0.5047' ;;
			seashell) COLOR='-x 0.3397 -y 0.3353' ;;
			sienna) COLOR='-x 0.5714 -y 0.3559' ;;
			silver) COLOR='-x 0.3227 -y 0.329' ;;
			sky-blue) COLOR='-x 0.2206 -y 0.2948' ;;
			slate-blue) COLOR='-x 0.2218 -y 0.1444' ;;
			slate-gray) COLOR='-x 0.2762 -y 0.3009' ;;
			snow) COLOR='-x 0.3292 -y 0.3285' ;;
			spring-green) COLOR='-x 0.1994 -y 0.5864' ;;
			steel-blue) COLOR='-x 0.183 -y 0.2325' ;;
			tan) COLOR='-x 0.4035 -y 0.3772' ;;
			teal) COLOR='-x 0.17 -y 0.3403' ;;
			thistle) COLOR='-x 0.3342 -y 0.2971' ;;
			tomato) COLOR='-x 0.6112 -y 0.3261' ;;
			turquoise) COLOR='-x 0.1732 -y 0.3672' ;;
			violet) COLOR='-x 0.3644 -y 0.2133' ;;
			wheat) COLOR='-x 0.3852 -y 0.3737' ;;
			white) COLOR='-x 0.3227 -y 0.329' ;;
			white-smoke) COLOR='-x 0.3227 -y 0.329' ;;
			yellow) COLOR='-x 0.4432 -y 0.5154' ;;
			yellow-green) COLOR='-x 0.3517 -y 0.5618' ;;
			*) COLOR='--alert select' ;;
		esac
	fi
	echo "$COLOR"
}


# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;
