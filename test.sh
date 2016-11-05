#! /bin/bash

sudo ./install.sh purge -y > /dev/null 2>&1
sudo ./install.sh install --test 1 > /dev/null 2>&1

bats test
EXIT=$?

shellcheck bin/* base.sh install.sh
EXIT2=$1

if [ "$EXIT" != 0 ]; then
  EXIT=$EXIT2
fi

sudo ./install.sh purge -y > /dev/null 2>&1

exit "$EXIT"
