#! /bin/bash

sudo ./install.sh uninstall -y > /dev/null 2>&1
sudo ./install.sh install --test 1 > /dev/null 2>&1

bats test
