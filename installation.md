---
title: Installation
---

## Requirements

* shell (sh, ash, dash, bash .. )
* curl


### Using `curl`

```
curl -kL -o Hue-shell.tar.gz https://github.com/Josef-Friedrich/Hue-shell/archive/master.tar.gz
tar -xzvf Hue-shell.tar.gz
cd Hue-shell-master
sudo ./install.sh install
```

### Using `git`

```
git clone git@github.com:Josef-Friedrich/Hue-shell.git
cd Hue-shell
sudo ./install.sh install
```

You need a working Philips Hue setup, the IP address of your bridge and
a username to access the bridge. 

Please read the [informations on the Hue website](http://www.developers.meethue.com/documentation/getting-started) 
how to achieve that.  Now edit the file `/etc/hue-shell/hue-shell.conf` 
and fill in the values for the variables `IP` and `USERNAME`.

For some scene commands you need the `ALL_LIGHTS` variable. Use 
`hue get all` to retrieve the ids of your connected Hue lights and put 
the comma separated id list in the configuration file.

```
vim /etc/hue-shell/hue-shell.conf
```

```
IP="192.168.1.2"
USERNAME="yourusername"
ALL_LIGHTS="1,2,3"
```

This configuration file has to be written in the Shell script syntax. 
Because of this never put whitespaces around the equal sign. The 
quotation marks can be omitted.



