---
title: huescene-sequence
---

```
########################################################################
# huescene-sequence
########################################################################

USAGE
	huescene-sequence <options>

OPTIONS
	-b, --brightness
		Brightness of the lights (0 - 255).

	-h, --help
		Show this help message.

	-H, --huesequence
		A sequence of hue color values (0 - 65535) seperated by
		commas. No spaces are allowed between the values.

	-s, --sleeptime
		Time between the color changes in seconds.

	-t, --transitiontime
		Transition time in seconds.

DESCRIPTION
	'hue-sequence' changes all lights at the same time in a certain
	sequence.

EXAMPLES
	huescene-sequence --huesequence 46920,56100,25500,36210,12750
	huescene-sequence -H 46920,12750,25500 -t 2 -s 20 -b 255
	huescene-sequence
```

