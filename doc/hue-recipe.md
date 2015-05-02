########################################################################
# HUE RECIPE
########################################################################

```
Usage: hue recipe <option>

DESCRIPTION
        This scene command shows white colors in different color
        temperatures. All lights displaying the same color temperature.

OPTIONS (only one option is possible)
        -c, --concentrate
                This option creates a light situation best for
                concentrating. It show a medium cold color temperature.

        -d, --default
                Show the default white color temperature, which the
                lights showing, when they turned on.

        -e, --energize
                The option 'energize' produces the coldest white color
                of all recipes.

        -h, --help
                Show this help text.

        -R, --reading
                The hue lights displaying a medium warm white color
                temperature, which is good for reading.

        -r, --relax
                Let the hue lights shine in a very warm white color,
                which is optimized for relaxing.

SORTING BY COLOR TEMPERATURE
        COLD -> energize (156) -> concentrate (233) -> readintg (346)
        -> default (369) -> relax (443) -> WARM

        The numbers in parentheses are Mired color temperature values.6)
        -> default (369) -> relax (443) -> WARM

EXAMPLES
        hue recipe --reading
        hue recipe -r
```
