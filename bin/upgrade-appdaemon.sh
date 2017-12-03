#!/bin/bash

NAME="appdaemon"
PROJECT="ha"
IMAGE="stevebargelt/appdaemon-rpi"

########## header(text, colour) - echo text in colour, if colour is not set use red
#
# 0 - Black, 1 - Red, 2 - Green, 3 - Yellow, 4 - Blue, 5 - Magenta,
# 6 - Cyan,  7 - White
#
##########
# docker-compose -p ha stop home-assistant
# docker-compose -p ha rm --force home-assistant
# docker pull homeassistant/raspberrypi-homeassistant
# docker-compose -p ha up -d

header() {
  if [ -z "$2" ]; then
    echo -e "$(tput setaf 1)$1$(tput sgr 0)"
  else
    echo -e "$(tput setaf $2)$1$(tput sgr 0)"
  fi
}

##########
DOCKERCOMPOSE = `which docker-compose`
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

if which docker-compose >/dev/null; then
  header "Found Docker Compose" 6
  DOCKERCOMPOSE=`which docker-compose`
else
  header "Docker Compose not found. Exiting..." 1
  exit 1
fi

header "Stopping docker container..." 6

if $DOCKERCOMPOSE -p $PROJECT stop $NAME; then
  header "Stopped docker container" 2 
else
  header "Failed to stop docker container or container already stopped. Continuing..." 1
fi


header "Removing docker container..." 6

if $DOCKERCOMPOSE -p $PROJECT rm --force $NAME; then
  header "Removed docker container" 2 
else
  header "Failed to remove docker container or container already removed. Continuing..." 1
fi


header "Pulling Latest Image" 6

if $DOCKER pull $IMAGE; then
  header "Pulled image" 2 
else
  header "Failed to image" 1
  exit 1
fi


header "Starting Project" 6

if $DOCKERCOMPOSE -p $PROJECT up -d; then
  header "Started Project" 2
else
  header "Failed to start Project" 1
  exit 1
fi

exit 0
