---
title: Integration with SysVinit
---

`Hue-shell` delivers a [shell script]({{ site.repo_master }}/startup/SysVinit) which can be
used for SysVint.

To start the `Hue-shell` daemon:

```
/etc/init.d/hue-shell start
```

To stop the `Hue-shell` daemon:

```
/etc/init.d/hue-shell stop
```

Edit the default scene section in `/etc/hue-shell/hue-shell.conf` to 
specify the wanted scene for `hueshell-default`.

```sh
# Default light scene for the startup daemon.                                   
#DEFAULT_SCENE="huescene-sequence -H 4000,12750,6000,14500 -s 3 -t 1 -b 255"    
#DEFAULT_SCENE="huescene-breath -H 46000:48000 -b 1:255 -t 15:20"               
DEFAULT_SCENE="hueload-random" 
```