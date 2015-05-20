`Hue-shell` is a collection of shell scripts to control the Hue lamps
from Philips. It is designed for embedded operating systems with very
limited resources (successfully tested on the old and outdated wifi
router "Linksys WRT54GL"). `Hue-shell` runs on many shells (sh, dash,
ash, bash) and many UNIX operating systems (Linux, MacOS X, FreeBSD,
OpenWRT). `Hue-shell` works well in a small BusyBox environment.

# Installation
--------------

## Requirements

* shell (sh, ash, dash, bash .. )
* curl

```
git clone git@github.com:Josef-Friedrich/Hue-shell.git
cd Hue-shell
sudo ./install.sh
```

You need a working Philips Hue setup, the IP address of your bridge and
a username to access the bridge. Please read
http://www.developers.meethue.com/documentation/getting-started for more
informations to achieve that. Than edit the file '/etc/hue-shell/hue-
shell.conf' and fill in the values for IP and USERNAME.

```
vim /etc/hue-shell/hue-shell.conf
```

```
IP="192.168.1.2"
USERNAME="yourusername"
```

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
generation init system of Linux systemd.

## SysVinit

`Hue-shell` delivers a [shell script](startup/SysVinit) which can be
used for SysVint.

# Commands
----------

## Basic commands

* [hue](doc/hue.txt)

## Load commands

* [hueload-default](doc/hueload-default.txt)
* [hueload-random](doc/hueload-random.txt)
* [hueload-scene](doc/hueload-scene.txt)

## One color commands

* [huecolor-basic](doc/huecolor-basic.txt)
* [huecolor-recipe](doc/huecolor-recipe.txt)

## Scene commands

* [huescene-breath](doc/huescene-breath.txt)
* [huescene-pendulum](doc/huescene-pendulum.txt)
* [huescene-sequence](doc/huescene-sequence.txt)
