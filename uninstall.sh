#! /bin/sh

INSTALL_DIR='/usr'

rm -rf /etc/hue-shell
rm -rf $INSTALL_DIR/lib/hue-shell
rm -f $INSTALL_DIR/bin/hue*
rm -f /etc/init.d/hue
rm -rf /var/run/hue-shell
rm -f /etc/triggerhappy/triggers.d/hue.conf

# vim: set ts=8 sw=8 sts=8 et :
# sublime: tab_size 8;