Warning! Experimental code!

NAME
        hue - control the Hue lights from Philips using a unix shell.

SYNOPSIS
        hue <command> <options>

DESCRIPTION
        Hue-Shell is a shell script to control the Hue lamps from
        Philips (https://www.meethue.com).

REQUIREMENTS
        curl

INSTALLATION
        Hue shell needsCreate a ini file in /etc/hue.ini.


Usage: hue set <options>

      --on
              On state of the light.

      --off
              Off state of the light.

      -b, --bri
              The brightness value to set the light to.

      -h, --hue
              The hue value to set light to.

      -s, --sat
              Saturation of the light.

      -x
              The x coordinates in CIE color space.

      -y
              The y coordinates in CIE color space.

      -c, --ct
              The Mired Color temperature of the light.

      -a, --alert
              The alert effect, is a temporary change to the bulb’s
              state.

      -e, --effect
              The dynamic effect of the light. Currently “none” and
              “colorloop” are supported.

      -t, --transitiontime
              The duration of the transition from the light’s current
              state to the new state.

Usage: hue recipe <option>

This scene command shows white colors in different color temperatures.
All lights displaying the same color temperature.

The options are (only one option is possible):

        -c,  --concentrate
                This option creates a light situation best for
                concentrating. It show a medium cold color temperature.

        -d,  --default
                Show the default white color temperature, which the
                lights showing, when they turned on.

        -e,  --energize
                The option 'energize' produces the coldest white color
                of all recipes.

        -h,  --help
                Show this help text.

        -R,  --reading
                The hue lights displaying a medium warm white color
                temperature, which is good for reading.

        -r,  --relax
                Let the hue lights shine in a very warm white color,
                which is optimized for relaxing.

| COLD ->
  -> energize (156)
  -> concentrate (233)
  -> readintg (346)
  -> default (369)
  -> relax (443)
-> WARM |

The numbers in parentheses are Mired color temperature JSON.
