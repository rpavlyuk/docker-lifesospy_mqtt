#!/bin/bash

LOGFILE=$1
PATTERN=$2
ACTION=$3

if [ -z "$LOGFILE" ]
then
  echo "Log file parameter (#1) not found!"
  exit 1
fi

if [ -z "$PATTERN" ]
then
  echo "Pattern parameter (#2) not found!"
  exit 1
fi

if [ -z "$ACTION" ]
then
  echo "Action parameter (#3) not found!"
  exit 1
fi

tail -fn0 "$LOGFILE" | \
while read line ; do
        echo "$line" | grep "$PATTERN"
        if [ $? = 0 ]
        then
          echo "Found pattern \"$PATTERN\" in log file \"$LOGFILE\": running action code \"$ACTION\""
          $ACTION
        fi
done
