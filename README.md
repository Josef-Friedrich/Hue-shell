Hue shell is a collection of shell scripts to control the Hue lamps from
Philips (https://www.meethue.com). Hue shell runs on many shells (sh, dash, ash, bash) and UNIX operating systems (Linux, MacOS X, FreeBSD, OpenWRT). 

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

    git clone git@github.com:Josef-Friedrich/Hue-shell.git $HOME/Hue-shell
    ln -s $HOME/Hue-shell/config/hue-shell.conf /etc/hue-shell
    ln -s $HOME/Hue-shell/startup/SysVinit /etc/init.d/hue

You have to set an username. Use this documentation for.
    http://www.developers.meethue.com/documentation/getting-started

You need a working Philips Hue setup, the IP address of your
bridge and a username to access the bridge. Please read
http://developers.meethue.com/gettingstarted.html for more
informations to achieve that. Than edit the file 'hue' and fill
in the values for IP and USERNAME.


https://github.com/wertarbyte/triggerhappy

```
cd /etc/triggerhappy/triggers.d
ln -s $HOME/hue-shell/config/triggerhappy.conf
```

# Commands

## Basic commands

* [hue-set](doc/hue-set.md)

## One color commands

* [hue-color](doc/hue-color.md)
* [hue-recipe](doc/hue-recipe.md)

## Scene commands

