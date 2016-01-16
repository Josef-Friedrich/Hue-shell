#! /bin/sh

# For development purposes only!

IP="192.168.2.31"
USERNAME="joseffriedrich"
ALL_LIGHTS="1,2,3,4,5,6,7,8,9"

_replace() {
	sed -i "s;$1;$2;" /etc/hue-shell/hue-shell.conf
}

if [ "$1" = "download" ]; then
	cd /tmp
	curl -kL -o Hue-shell.tar.gz https://github.com/Josef-Friedrich/Hue-shell/archive/master.tar.gz
	tar -xzvf Hue-shell.tar.gz
	cd Hue-shell-master
fi

./install.sh

if [ "$1" = "download" ]; then
	rm -rf /tmp/Hue-shell-master
	rm -f /tmp/Hue-shell.tar.gz
fi

_replace 'IP="192.168.1.2"' "IP=\"$IP\""
_replace 'USERNAME="yourusername"' "USERNAME=\"$USERNAME\""
_replace 'ALL_LIGHTS="1,2,3"' "ALL_LIGHTS=\"$ALL_LIGHTS\""

