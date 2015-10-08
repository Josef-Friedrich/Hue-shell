---
title: Integration with triggerhappy
---

`Hue-shell` provides a 
[configuration file]({{ site.repo_master }}/triggerhappy/hue-shell.conf)
for [triggerhappy](https://github.com/wertarbyte/triggerhappy).

Triggerhappy is a lightweight hotkey daemon and allows to control the
Hue lights with keyboard shortcuts. If you have already installed
triggerhappy and the directory `/etc/triggerhappy/triggers.d` exists,
the install script puts a sample configuration file on the right place.

Feel free to modify the file '/etc/triggerhappy/triggers.d/hue-shell.conf' 
as you like:

```
# Fundamental tasks
# <event name>  <event value> <command line>
KEY_ESC		1	hue set all --off
KEY_ENTER	1	hue set all --on
KEY_SPACE	1	hue stop
KEY_SPACE	2	hue reset
KEY_STOPCD	1	hue stop
KEY_MIN_INTERESTING 1	hue kill
KEY_FILE	1       hue kill
KEY_VOLUMEDOWN	1	hue kill
KEY_VOLUMEUP	1	hue kill
KEY_PREVIOUSSONG 1	hue kill
KEY_PLAYPAUSE	1	hue kill
KEY_NEXTSONG	1	hue kill
#
# Simple colors on all lights.
#
KEY_1		1	huecolor-basic 0
KEY_2		1	huecolor-basic 5957
KEY_3		1	huecolor-basic 11914
KEY_4		1	huecolor-basic 17871
KEY_5		1	huecolor-basic 23828
KEY_6		1	huecolor-basic 29785
KEY_7		1	huecolor-basic 35742
KEY_8		1	huecolor-basic 41699
KEY_9		1	huecolor-basic 47656
KEY_0		1	huecolor-basic 53613
KEY_MINUS	1	huecolor-basic 59570
KEY_EQUAL	1	huecolor-basic 65527
#
# Recipes
#
KEY_Q		1	huecolor-recipe --relax
KEY_W		1	huecolor-recipe --concentrate
KEY_E		1	huecolor-recipe --energize
KEY_R		1	huecolor-recipe --reading
KEY_T		1	huecolor-recipe --default
#
# Color sequence
#
# -H = --huesequence
# -s = --sleeptime
# -t = --transitiontime
# -b = --brightness
#
KEY_A		1	huescene-sequence
KEY_S		1	huescene-sequence -H 46920,12750,25500 -t 2 -s 20 -b 255
#
# Random breath
#
# -l = --lights
# -H = --hue-range
# -t = --time-range
# -b = --brightness-range
#
KEY_Z		1	huescene-breath -H 0:8000
KEY_X		1	huescene-breath -H 30000:50000
KEY_C		1	huescene-breath -H 12345:23456 -t 2:3 -b 1:5
KEY_V		1	huescene-breath -H 0:65000 -t 1:1 -b 2:6
KEY_B		1	huescene-breath -H 46000:48000 -b 5:60 -t 1:3
```
