
Hue-Bash is a collection of bash scripts to control the [Hue lamps from Philips](https://www.meethue.com).

# Requirements
* [curl](curl)
* [jq](http://stedolan.github.io/jq/)

# Installation

Create a ini file in ```/etc/hue.ini```.

Sample file:

```
IP="192.168.2.31"
USERNAME="username"
```

# Commands

## hue
------

### hue help

```
hue help
```
Show help

### hue set

```
hue set <lamp> <json>
```
```<lamp>```: Lamp number or 'all'.
### hue get

```
hue get <lamp> 
```
```<lamp>```: Lamp number or 'all'.
### hue ping

```
hue ping <lamp>
```
```<lamp>```: Lamp number or 'all'.

### hue stop

```
hue stop
```

### hue debug

```
hue debug
```

## huectrl
----------

```
huectrl start
```

```
huectrl stop
```

## huescene
-----------


### huescene info

```
huectrl info
```

### huescene stop

```
huectrl stop
```