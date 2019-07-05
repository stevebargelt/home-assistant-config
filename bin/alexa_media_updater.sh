#!/bin/bash

# Location of alexa_media
loc="/Users/steve/ha/home-assistant-config/custom_components/alexa_media"
backup_loc="/Users/steve/ha/home-assistant-config/custom_components/alexa_media_bk"

#Get raw links
links=$(curl -s  "https://raw.githubusercontent.com/keatontaylor/alexa_media_player/master/custom_components.json" | jq -r .alexa_media.resources[])

# Check if folders exist
if [ ! -d $loc ]; then
    echo 'No installation found. Installing...'

    # Location of component files
    init=$(curl -s  "https://raw.githubusercontent.com/keatontaylor/alexa_media_player/master/custom_components.json" | jq -r .alexa_media.remote_location)
    const=$(echo $links | cut -d " " -f 1)
    media_player=$(echo $links | cut -d " " -f 2)
    notify=$(echo $links | cut -d " " -f 3)
    alarm=$(echo $links | cut -d " " -f 4)
    manifest=$(echo $links | cut -d " " -f 5)
    services=$(echo $links | cut -d " " -f 6)

    # Check if folders exist
    if [ ! -d $loc ]; then
      mkdir $loc
    fi

    # Download files
    wget $init -P $loc
    wget $alarm -P $loc
    wget $const -P $loc
    wget $manifest -P $loc
    wget $media_player -P $loc
    wget $notify -P $loc
    wget $services -P $loc

    exit
fi

# Check running version
act_version=$(cat $loc/const.py | grep -Poi "\'(\d.\d.\d)\'" | cut -c 2-6 | tr -d '.' )
new_version=$(curl -s  "https://raw.githubusercontent.com/keatontaylor/alexa_media_player/master/custom_components.json" | jq -r .alexa_media.version | tr -d '.')

#If running version is not newest, updating
if [ $act_version -lt $new_version ]; then
    echo 'Found a new version. Updateing...'

    # Location of component files
    init=$(curl -s  "https://raw.githubusercontent.com/keatontaylor/alexa_media_player/master/custom_components.json" | jq -r .alexa_media.remote_location)
    const=$(echo $links | cut -d " " -f 1)
    media_player=$(echo $links | cut -d " " -f 2)
    notify=$(echo $links | cut -d " " -f 3)
    alarm=$(echo $links | cut -d " " -f 4)
    manifest=$(echo $links | cut -d " " -f 5)
    services=$(echo $links | cut -d " " -f 6)

    # Check if folders exist
    if [ ! -d $loc ]; then
      mkdir $loc
    fi

    if [ ! -d $backup_loc ]; then
     mkdir $backup_loc
    fi

    # Clean backup folder
    rm -rf $backup_loc/*

    # Make backup
    cp -R $loc/* $backup_loc

    # Clean alexa_media folder
    rm -rf $loc/*

    # Download files
    wget $init -P $loc
    wget $alarm -P $loc
    wget $const -P $loc
    wget $manifest -P $loc
    wget $media_player -P $loc
    wget $notify -P $loc
    wget $services -P $loc

else
     echo 'No update found. Exiting.'
     exit
fi
