#! /bin/bash

sudo ./install.sh reinstall -y > /dev/null 2>&1

bats test
