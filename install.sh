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

# /etc/init.d
cp startup/SysVinit /etc/init.d/hue

