#! /bin/sh

RANDOM="0"

# http://rosettacode.org/wiki/Linear_congruential_generator
# The Microsoft version

SECONDS=$(date +%s)

while true; do
  RANDOM=$((((214013 * $RANDOM) + 2531011 + $SECONDS) % 2147483648))
  RANDOM=$(($RANDOM / 65536))
  echo $RANDOM
done


