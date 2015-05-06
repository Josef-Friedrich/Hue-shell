########################################################################
# hueload-random
########################################################################

```
'hueload-random' loads a random light scene, which is picked from the
config file $CONFIGURATION_PATH/random-scenes.conf.

hueload-random <options>

Options:
    -a, --all     Execute all scenes line by line without random.
    -d, --debug   Enable debug mode, which puts out the executed scene command.
    -e, --edit    Edit the random scenes file in the default text editor.
    -l, --list    List all scenes commands without blank lines and without
                  comments.
    -s, --show    Show the random scenes file.
```