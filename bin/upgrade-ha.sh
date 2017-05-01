#!/bin/bash

NAME="home-assistant"
CONFIG="/usr/local/etc/homeassistant"
LOCALTIME="/etc/localtime"
LOCALBACKUP="/home/graeme/home-assistant-backup"
ZWAVEDEVICE="/dev/ttyACM0"

########## header(text, colour) - echo text in colour, if colour is not set use red
#
# 0 - Black, 1 - Red, 2 - Green, 3 - Yellow, 4 - Blue, 5 - Magenta,
# 6 - Cyan,  7 - White
#
##########

header() {
  if [ -z "$2" ]; then
    echo -e "$(tput setaf 1)$1$(tput sgr 0)"
  else
    echo -e "$(tput setaf $2)$1$(tput sgr 0)"
  fi
}

##########

DOCKER=`which docker`

header "Home Assistant Upgrade for Docker" 6
header "---------------------------------" 6
printf "\n"
if which docker >/dev/null; then
  header "Found Docker" 6
  DOCKER=`which docker`
else
  header "Docker not found. Exiting..." 1
  exit 1
fi

header "Stopping docker container..." 6

if $DOCKER stop $NAME; then
  header "Stopped docker container" 2 
else
  header "Failed to stop docker container or container already stopped. Continuing..." 1
fi


header "Removing docker container..." 6

if $DOCKER rm --force $NAME; then
  header "Removed docker container" 2 
else
  header "Failed to remove docker container or container already removed. Continuing..." 1
fi


header "Pulling Latest Home Assistant" 6

if $DOCKER pull homeassistant/home-assistant:dev; then
  header "Pulled Home Assistant DEV" 2 
else
  header "Failed to pull Home Assistant DEV" 1
  exit 1
fi


header "Starting Home Assistant" 6

if $DOCKER run --restart=always -d --name="$NAME" -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --device=/dev/ttyUSB0:/zwaveusbstick:rwm --net=host homeassistant/home-assistant:dev; then
  header "Started Home Assistant" 2
else
  header "Failed to start Home Assistant" 1
  exit 1
fi

exit 0
