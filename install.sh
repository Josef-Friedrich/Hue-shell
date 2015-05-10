#! /bin/sh

INSTALL_DIR='/usr'

# etc
mkdir -p /etc/hue-shell
cp -r config/* /etc/hue-shell

# lib
mkdir -p $INSTALL_DIR/lib/hue-shell
cp base.sh $INSTALL_DIR/lib/hue-shell

# bin
cp bin/hue* $INSTALL_DIR/bin

# run
RUN='/var/run/hue-shell'
mkdir -p $RUN
RUN_FILES="$RUN/hue-shell.pids $RUN/hue-shell-random.seed"
touch $RUN_FILES
chmod 666 $RUN_FILES

# /etc/init.d
cp startup/SysVinit /etc/init.d/hue

# triggerhappy
if [ -f /etc/triggerhappy/triggers.d ]; then
	cp triggerhappy/hue.conf /etc/triggerhappy/triggers.d/
fi
