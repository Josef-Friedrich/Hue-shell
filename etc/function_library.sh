#! /bin/bash

##
# Loop function.
##
function loop {
  (
    while true; do
      eval "$*"
    done
  ) &
  echo $! >> $PIDFILE
}

##
# Random range function.
#
# $1 START
# $2 END
##
function range {
  START=$1
  END=$2

  END=$((END + 1))

  RANGE=$((END - START))

  # $RANDOM is a number between 0 and 32767
  BIG_RANDOM=$((RANDOM * 4 + RANDOM % 4))

  NUMBER_IN_RANGE=$((BIG_RANDOM % RANGE))

  echo $((NUMBER_IN_RANGE + START))
}

##
# Sleep as long as transitiontime.
# TIME=$1
##
function huesleep {
  TIME=$1

  sleep ${TIME%?}.${TIME: -1}
}
