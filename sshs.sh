#!/bin/bash

NUM_OF_ARGS="$#"
MODE=""
FILENAME="addresses.txt"
KEY="$2"

invalid() {
	echo "Usage error. $1"
	exit 1
}

if [ "$NUM_OF_ARGS" -lt 1 ] || [ "$NUM_OF_ARGS" -gt 2 ]; then
	invalid "Invalid number of arguments."
fi

if [ "$1" = "-c" ]; then
	MODE="CREATE"
elif [ "$1" = "-d" ]; then
	MODE="DELETE"
elif [ "$1" = "-a" ]; then
	MODE="ATTACH"
elif [ "$1" = "-h" ]; then
	MODE="HELP"
elif [ "$1" = "-l" ]; then
	MODE="LIST"
else
	invalid "Invalid mode."
fi


if [ ! -f "$FILENAME" ]; then
	touch "$FILENAME"
fi

COUNT=$(awk -v key="$KEY" '$1 == key {print}' "$FILENAME" | wc -l)

create() {
	if [ "$COUNT" -gt 0 ]; then
		echo "Key $KEY already exists."
		exit 0
	fi
	echo Enter your username:
	read USERNAME
	echo Enter the host/IP:
	read HOST
	ADDRESS="${USERNAME}@${HOST}"
	echo "Confirm your address (y/n): ${ADDRESS}"
	read CONFIRM
	if [ "$CONFIRM" = "n" ]; then
		echo Process exited.
		exit 0
	fi		
	echo "${KEY} ${ADDRESS}" >> "$FILENAME"
	echo "Successfully added address."
	exit 0
}

delete() {
	if [ "$COUNT" -eq 0 ]; then
		echo "Cannot delete key/address because it does not exist."
		exit 0
	fi
	sed -i /"^$KEY "/d "$FILENAME"
	echo "Successfully deleted address."
}

attach() {
	if [ "$COUNT" -eq 0 ]; then
		echo "Cannot attach to key/address because it does not exist."
		exit 0
	fi	
	echo "Attempting to connect to ${ADDRESS}..."
	ADDRESS=$(awk -v key="$KEY" '$1 == key {print $2}' "$FILENAME")
	ssh "$ADDRESS"
}

list() {
	cat "$FILENAME"
}

if [ "$MODE" = "CREATE" ]; then
	create
elif [ "$MODE" = "DELETE" ]; then
	delete
elif [ "$MODE" = "ATTACH" ]; then
	attach
elif [ "$MODE" = "LIST" ]; then
	list
fi
