#! /bin/sh

INSTALL_DIR='/usr'

rm -rf /etc/hue-shell
rm -rf $INSTALL_DIR/lib/hue-shell
rm -f $INSTALL_DIR/bin/hue*
rm -f /etc/init.d/hue
rm -f /etc/triggerhappy/triggers.d/hue.conf
