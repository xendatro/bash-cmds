#!/bin/bash


NUM_OF_ARGS="$#"
MODE=""

invalid() {
	echo "Usage error. $1"
	exit 1
}

if [ ! "$NUM_OF_ARGS" -eq 2 ]; then
	invalid "Invalid number of arguments.
fi

if [ "$1" = "-c" ]; then
	MODE="CREATE"
elif [ "$1" = "-d" ]; then
	MODE="DELETE"
elif [ "$1" = "-a" ]; then
	MODE="ATTACH"
else
	invalid "Invalid mode."
fi


