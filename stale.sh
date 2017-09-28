#!/bin/sh

#
# Checks if a logfile hasnt been written to in the set amount of time. 
# If its gone stale, email user last 10 lines of file.
# 
# USAGE: ./stale -60 /my/log/file.log
# This will check the log file every 60 minutes for a change.
#

TIME_LIMIT=
LOG_PATH=
LAST_TIME=
CURRENT_TIME=
LAST_10=


#mail stuff
SUBJECT="Your log file is stale, heres the last 10 lines"
USER=$USER
AT="@broadinstitute.org"

function GET_TIME { 

	eval "stat --format=%Y $LOG_PATH" 
}

if [ "$#" -gt 2 ]; then
    echo "You may only enter 1 log path at a time."
fi


if [[ $1 =~ ^-?[0-9]+$ ]] ; then	
	TIME_LIMIT="${1//-}"
else
	printf "You must enter a valid time limit in minutes on this log file. \nFor example 'stale -60 /path/log.log'"
fi	


if [[ -e $2 ]] ; then
	LOG_PATH=$2
else
	printf "You must enter a valid file.\n"
fi

LAST_TIME=$( GET_TIME )
sleep "$TIME_LIMIT"s

while true; do 
	CURRENT_TIME="$( GET_TIME )"

	if [[ $CURRENT_TIME -eq $LAST_TIME ]] ; then
		LAST_10="$( tail $LOG_PATH )"
		mail -s "$SUBJECT" "$USER$AT" <<< "$LAST_10"
		exit
	else
		sleep "$TIME_LIMIT"s
		LAST_TIME=$CURRENT_TIME
	fi
done
