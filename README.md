`Hue-shell` is a collection of shell scripts to control the Hue lamps
from Philips. 

```
                    _________________________
                   /                         \
                  +    ___________________    +
                  |   /                   \   |                      .
                  |   + _$ hue set 1 --on  +  |            .    +    ,
                  |   |                    |  |             \   '   /
  ,+.             |   +                    +  |              ` ,+. '
 (   )            |   \___________________/   |           +-+ (   ) +-+
  \ /     -->     +  /+\               _      +     -->        \ /
 _+=+_             \_________________________/                _+=+_
+_____+              !______________________!                +_____+

```

It is designed for embedded operating systems with very
limited resources (successfully tested on the old and outdated wifi
router "Linksys WRT54GL").

`Hue-shell` runs on many shells (sh, dash,
ash, bash) and many UNIX operating systems (Linux, MacOS X, FreeBSD,
OpenWrt). `Hue-shell` works well in a small BusyBox environment. Out 
of the box `Hue-shell` runs on many single-board computer like 
Raspberry Pi, Cubieboard, BeagleBone etc.

# Features

* Versatile basis command `hue set ...`
* Requires very little resources, runs in a small UNIX environments
* Moving light scenes to create a ambient and decent atmosphere (`huescene-breath` `..-pendulum`, `..-sequence`)
* Background services to detect reachable bridge and blubs.

For further documentation please visit the project site:

http://josef-friedrich.github.io/Hue-shell/