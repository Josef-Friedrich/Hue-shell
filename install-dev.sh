#! /bin/sh

# For development purposes only!

_replace() {
	sed -i "s;$1;$2;" /etc/hue-shell/hue-shell.conf
}

./install.sh

_replace 'IP="192.168.1.2"' 'IP="192.168.2.31"'
_replace 'USERNAME="yourusername"' 'USERNAME="joseffriedrich"' 
_replace 'ALL_LIGHTS="1,2,3"' 'ALL_LIGHTS="1,2,3,4,5,6,7,8,9"'

