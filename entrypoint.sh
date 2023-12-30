#!/bin/sh

sudo service dbus start
sudo service bluetooth start
sudo chown $USERNAME:$USERNAME /app/config

CONFIG=/app/config/nuki.yaml
if [ -z $NUKI_MAC ]; then
	echo "NUKI_MAC is not set. Searching for bluetooth devices"
	echo "Set NUKI_MAC with the correct nuki device and restart for pairing."
	sudo timeout -s SIGINT 5s hcitool -i hci0 lescan
	exit
fi
if [ ! -f "$CONFIG" ]; then
	python . --generate-config > $CONFIG
	python . --config=$CONFIG --pair $NUKI_MAC
fi

python . --config=$CONFIG
