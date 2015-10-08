---
title: huescene-pendulum
---

```
########################################################################
# huescene-pendulum
########################################################################

USAGE
	huescene-pendulum <options>

OPTIONS
	-c1, --color1
		Hue color value (0 - 65535) for lights group 1.

	-c2, --color2
		Hue color value (0 - 65535) for lights group 2.

	-h, --help
		Show this help message.

	-l1, --lights1
		Lights group 1 (comma seperated numbers, e. g.: 1,2,3).

	-l2, --lights2
		Lights group 2 (comma seperated numbers, e. g.: 4,5,6).

	-s, --switchtime
		Time in seconds to switch between the two lights groups.

	-t, --transitiontime
		Transition time for the color change (-t 10 = one second).

DESCRIPTION
	'huescene-pendulum' switches two group of lights between two
	colors.

EXAMPLES
	huescene-pendulum -l1 1,2 -l2 3 -c1 5000 -c2 20000 -s 4 -t 30
	huescene-pendulum -l1 1,2,7 -l2 3,8,9 -c1 65000 -c2 45831 -s 5 -t 10
	huescene-pendulum
```