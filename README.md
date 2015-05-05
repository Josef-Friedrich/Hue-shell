`Hue-shell` is a collection of shell scripts to control the Hue lamps from
Philips. It is designed for embedded operating systems with very limited
resources (successfully tested on the old and outdated wifi router 
"Linksys WRT54GL"). `Hue-shell` runs on many shells (sh, dash, ash, bash) 
and many UNIX operating systems (Linux, MacOS X, FreeBSD, OpenWRT).
`Hue-shell` works well in a small BusyBox environment.

# REQUIREMENTS

* shell (sh, ash, dash, bash)
* curl

# INSTALLATION

```
git clone git@github.com:Josef-Friedrich/Hue-shell.git
cd Hue-shell
sudo ./install.sh
```

You need a working Philips Hue setup, the IP address of your
bridge and a username to access the bridge. Please read
http://www.developers.meethue.com/documentation/getting-started for more
informations to achieve that. Than edit the file '/etc/hue-shell/hue-shell.conf' and fill
in the values for IP and USERNAME.

```
vim /etc/hue-shell/hue-shell.conf
```

```
IP="192.168.1.2"
USERNAME="yourusername"
```

# Integration with triggerhappy

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

* [hue-breath](doc/hue-breath.md)
* [hue-pendulum](doc/hue-pendulum.md)
* [hue-sequence](doc/hue-sequence.md)
