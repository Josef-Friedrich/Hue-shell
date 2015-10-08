`Hue-shell` is a collection of shell scripts to control the Hue lamps
from Philips. It is designed for embedded operating systems with very
limited resources (successfully tested on the old and outdated wifi
router "Linksys WRT54GL"). `Hue-shell` runs on many shells (sh, dash,
ash, bash) and many UNIX operating systems (Linux, MacOS X, FreeBSD,
OpenWRT). `Hue-shell` works well in a small BusyBox environment. Out 
of the box `Hue-shell` runs on many single-board computer like 
Raspberry Pi, Cubieboard, BeagleBone etc.

For further documentation please visit the project site:

http://josef-friedrich.github.io/Hue-shell/

# Integration
-------------

## triggerhappy

`Hue-shell` provides a [configuration file](triggerhappy/hue-shell.conf)
for [triggerhappy](https://github.com/wertarbyte/triggerhappy).
Triggerhappy is a lightweight hotkey daemon and allows to control the
Hue lights with keyboard shortcuts. If you have already installed
triggerhappy and the directory `/etc/triggerhappy/triggers.d` exists,
the install script puts the config file on the right place.

## systemd

`Hue-shell` supplies a [service file](startup/systemd) for the next
generation init system of Linux. To run `hueshell-default` on startup 
enable the `hue-shell.service`:

```
systemctl enable hue-shell.service
```

Edit the default scene section in `/etc/hue-shell/hue-shell.conf` to 
specify the wanted scene for `hueshell-default`.

```sh
# Default light scene for the startup daemon.                                   
#DEFAULT_SCENE="huescene-sequence -H 4000,12750,6000,14500 -s 3 -t 1 -b 255"    
#DEFAULT_SCENE="huescene-breath -H 46000:48000 -b 1:255 -t 15:20"               
DEFAULT_SCENE="hueload-random" 
```
## SysVinit

`Hue-shell` delivers a [shell script](startup/SysVinit) which can be
used for SysVint.

