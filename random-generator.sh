#! /bin/sh

SEED=0

# http://rosettacode.org/wiki/Linear_congruential_generator
# The Microsoft version

SEED=$(date +%S)

START=1
END=5

END=$((END + 1))

RANGE=$((END - START))


while true; do
  # 2**31 -> 2147483648
  SEED=$(((214013 * $SEED + 2531011) % 2147483648))
  # 2**14 -> 16384
  RANDOM=$(($SEED / 16384))
  NUMBER_IN_RANGE=$((RANDOM % RANGE))
  echo $((NUMBER_IN_RANGE + START))
done


