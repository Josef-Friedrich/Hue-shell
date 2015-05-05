#! /bin/sh

INSTALL_DIR='/usr'

mkdir -p /etc/hue-shell
cp -r config/* /etc/hue-shell
	
mkdir -p $INSTALL_DIR/lib/hue-shell
cp base.sh $INSTALL_DIR/lib/hue-shell

cp bin/hue* $INSTALL_DIR/bin

