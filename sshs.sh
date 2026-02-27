#!/bin/bash

NUM_OF_ARGS="$#"
MODE=""
FILENAME="$HOME/.addresses.txt"
KEY="$2"

invalid() {
	echo "Usage error. Type sshs -h for help menu. Error: $1"
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
	elif [ "$CONFIRM" = "y" ]; then
		echo "${KEY} ${ADDRESS}" >> "$FILENAME"
		echo "Successfully added address."
		exit 0	
	fi
	echo Unknown input. Aborting...
	exit 0
}

delete() {
	if [ "$COUNT" -eq 0 ]; then
		echo "Cannot delete key/address because it does not exist."
		exit 0
	fi
	sed -i "/^$KEY /d" "$FILENAME"
	echo "Successfully deleted address."
}

attach() {
	if [ "$COUNT" -eq 0 ]; then
		echo "Cannot attach to key/address because it does not exist."
		exit 0
	fi	
	ADDRESS=$(awk -v key="$KEY" '$1 == key {print $2}' "$FILENAME")
	echo "Attempting to connect to ${ADDRESS}..."
	ssh "$ADDRESS"
}

list() {
	cat "$FILENAME"
}

help() {
	echo "Usage sshs [option] [key]"
	echo "  -c [key]     - Create/bookmark an address"
	echo "  -d [key]     - Delete a saved address"
	echo "  -a [key]     - SSH into a saved address"
	echo "  -l           - List all saved addresses"
	echo "  -h           - Display help menu"
	exit 0
}

if [ "$MODE" = "CREATE" ]; then
	create
elif [ "$MODE" = "DELETE" ]; then
	delete
elif [ "$MODE" = "ATTACH" ]; then
	attach
elif [ "$MODE" = "LIST" ]; then
	list
elif [ "$MODE" = "HELP" ]; then
	help
fi
