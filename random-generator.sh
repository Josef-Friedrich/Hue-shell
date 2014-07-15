#! /bin/sh

while true; do
  RANDOM=$((214013 * $RANDOM + 2531011 % 2147483648))
  echo $RANDOM
done
