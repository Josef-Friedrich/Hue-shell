`Hue-shell` is a collection of shell scripts to control the Hue lamps
from Philips. It is designed for embedded operating systems with very
limited resources (successfully tested on the old and outdated wifi
router "Linksys WRT54GL"). `Hue-shell` runs on many shells (sh, dash,
ash, bash) and many UNIX operating systems (Linux, MacOS X, FreeBSD,
OpenWRT). `Hue-shell` works well in a small BusyBox environment. Out 
of the box `Hue-shell` runs on many single-board computer like 
Raspberry Pi, Cubieboard, BeagleBone etc.

# Installation
--------------

## Requirements

* shell (sh, ash, dash, bash .. )
* curl


### Using `curl`

```
curl -kL -o Hue-shell.tar.gz https://github.com/Josef-Friedrich/Hue-shell/archive/master.tar.gz
tar -xzvf Hue-shell.tar.gz
cd Hue-shell-master
./install.sh
```

### Using `git`

```
git clone git@github.com:Josef-Friedrich/Hue-shell.git
cd Hue-shell
sudo ./install.sh
```

You need a working Philips Hue setup, the IP address of your bridge and
a username to access the bridge. Please read
http://www.developers.meethue.com/documentation/getting-started for more
informations to achieve that. Than edit the file '/etc/hue-shell/hue-
shell.conf' and fill in the values for IP and USERNAME. For some scene
commands you need the `ALL_LIGHTS` variable. Use `hue get all` to
retrieve the ids of your connected Hue lights and put the comma
separated id list in the configuration file.

```
vim /etc/hue-shell/hue-shell.conf
```

```
IP="192.168.1.2"
USERNAME="yourusername"
ALL_LIGHTS="1,2,3"
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
