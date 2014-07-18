#! /bin/sh

. /home/jf/git-repositories/Hue-shell/hue > /dev/null

COUNT=0
while test "$COUNT" -le 500; do
  hue_range 1:100
  COUNT=$(($COUNT+1))
done