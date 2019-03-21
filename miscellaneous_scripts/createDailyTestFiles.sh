#!/bin/bash

# Will create one test file a day, up through the current date, in the directory path passed in as an argument.
#
# Parameters are assumed to be:
# $1 is the directory path of the files (e.g. /transactional/work/control/history/)
# $2 is the desired file prefix (e.g. clearCacheJob will result in clearCacheJob01.status)

DIRECTORY=$1
FILE_NAME=$2
CURRENT_MONTH=`date '+%m'`
CURRENT_DAY=`date '+%d'`

mkdir -p $DIRECTORY
cd $DIRECTORY

for (( i=1; i<=$CURRENT_DAY; i++ ))
do
  DAY=$i
  
  # Add 0 to day of the month since day must be DD for touch command
  if [ $i -lt 10 ]
  then
    DAY=0$i
  fi
  
  TIME=$CURRENT_MONTH$DAY"0000"
  touch -t $TIME $FILE_NAME$DAY.status
done